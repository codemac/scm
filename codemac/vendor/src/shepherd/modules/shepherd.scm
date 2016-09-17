;; shepherd.scm -- The daemon shepherd.
;; Copyright (C) 2013, 2014, 2016 Ludovic Courtès <ludo@gnu.org>
;; Copyright (C) 2002, 2003 Wolfgang Jährling <wolfgang@pro-linux.de>
;;
;; This file is part of the GNU Shepherd.
;;
;; The GNU Shepherd is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or (at
;; your option) any later version.
;;
;; The GNU Shepherd is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the GNU Shepherd.  If not, see <http://www.gnu.org/licenses/>.

(define-module (shepherd)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)   ;; Line-based I/O.
  #:autoload   (ice-9 readline) (activate-readline) ;for interactive use
  #:use-module (oop goops)      ;; Defining classes and methods.
  #:use-module (srfi srfi-1)    ;; List library.
  #:use-module (srfi srfi-26)
  #:use-module (srfi srfi-34)
  #:use-module (shepherd config)
  #:use-module (shepherd support)
  #:use-module (shepherd service)
  #:use-module (shepherd system)
  #:use-module (shepherd runlevel)
  #:use-module (shepherd args)
  #:use-module (shepherd comm)
  #:export (main))



(define (open-server-socket file-name)
  "Open a socket at FILE-NAME, and listen for connections there."
  (with-fluids ((%default-port-encoding "UTF-8"))
    (let ((sock    (socket PF_UNIX SOCK_STREAM 0))
          (address (make-socket-address AF_UNIX file-name)))
      (false-if-exception (delete-file file-name))
      (bind sock address)
      (listen sock 10)
      sock)))


;; Main program.
(define (main . args)
  (false-if-exception (setlocale LC_ALL ""))

  (let ((config-file #f)
	(socket-file default-socket-file)
        (pid-file    #f)
        (secure      #t)
        (logfile     default-logfile))
    ;; Process command line arguments.
    (process-args (program-name) args
		  ""
		  "This is a service manager for Unix and GNU."
		  not ;; Fail on unknown args.
		  (make <option>
		    #:long "persistency" #:short #\p
		    #:takes-arg? #t #:optional-arg? #t #:arg-name "FILE"
		    #:description "use FILE to load and store state"
		    #:action (lambda (file)
			       (set! persistency #t)
			       (and file
				    (set! persistency-state-file file))))
		  (make <option>
		    #:long "quiet"
		    #:takes-arg? #f
		    #:description "synonym for --silent"
		    #:action (lambda ()
                               ;; XXX: Currently has no effect.
                               #t))
		  (make <option>
		    #:long "silent" #:short #\S
		    #:takes-arg? #f
		    #:description "don't do output to stdout"
		    #:action (lambda ()
                               ;; XXX: Currently has no effect.
                               #t))
		  (make <option>
		    ;; It might actually be desirable to have an
		    ;; ``insecure'' setup in some circumstances, thus
		    ;; we provide it as an option.
		    #:long "insecure" #:short #\I
		    #:takes-arg? #f
		    #:description "don't ensure that the setup is secure"
		    #:action (lambda ()
                               (set! secure #f)))
		  (make <option>
		    #:long "logfile" #:short #\l
		    #:takes-arg? #t #:optional-arg? #f #:arg-name "FILE"
		    #:description "log actions in FILE"
		    #:action (lambda (file)
			       (set! logfile file)))
		  (make <option>
		    #:long "pid"
		    #:takes-arg? #t #:optional-arg? #t #:arg-name "FILE"
		    #:description "when ready write PID to FILE or stdout"
		    #:action (lambda (file)
			       (set! pid-file (or file #t))))
		  (make <option>
		    #:long "config" #:short #\c
		    #:takes-arg? #t #:optional-arg? #f #:arg-name "FILE"
		    #:description "read configuration from FILE"
		    #:action (lambda (file)
			       (set! config-file file)))
		  (make <option>
		    #:long "socket" #:short #\s
		    #:takes-arg? #t #:optional-arg? #f #:arg-name "FILE"
		    #:description
		    "get commands from socket FILE or from stdin (-)"
		    #:action (lambda (file)
			       (set! socket-file
				     (if (not (string=? file "-"))
					 file
				       ;; We will read commands
				       ;; from stdin, thus we
				       ;; enable readline if it is
				       ;; a non-dumb terminal.
				       (and (isatty? (current-input-port))
					    (not (string=? (getenv "TERM")
							   "dumb"))
					    (begin
					      (activate-readline)
					      ;; Finally, indicate that
					      ;; we use no socket.
					      #f)))))))
    ;; We do this early so that we can abort early if necessary.
    (and socket-file
         (verify-dir (dirname socket-file) #:secure? secure))
    ;; Enable logging as first action.
    (start-logging logfile)

    ;; Send output to log and clients.
    (set-current-output-port shepherd-output-port)

    ;; Start the 'root' service.
    (start root-service)
    ;; This _must_ succeed.  (We could also put the `catch' around
    ;; `main', but it is often useful to get the backtrace, and
    ;; `caught-error' does not do this yet.)
    (catch #t
      (lambda ()
        (load-in-user-module (or config-file (default-config-file))))
      (lambda (key . args)
	(caught-error key args)
	(quit 1)))
    ;; Start what was started last time.
    (and persistency
	 (catch 'system-error
	   (lambda ()
	     (start-in-order (read (open-input-file
				    persistency-state-file))))
	   (lambda (key . args)
	     (apply format #f (gettext (cadr args)) (caddr args))
	     (quit 1))))

    (when (provided? 'threads)
      ;; XXX: This terrible hack allows us to make sure that signal handlers
      ;; get a chance to run in a timely fashion.  Without it, after an EINTR,
      ;; we could restart the accept(2) call below before the corresponding
      ;; async has been queued.  See the thread at
      ;; <https://lists.gnu.org/archive/html/guile-devel/2013-07/msg00004.html>.
      (sigaction SIGALRM (lambda _ (alarm 1)))
      (alarm 1))

    ;; Stop everything when we get SIGINT.  When running as PID 1, that means
    ;; rebooting; this is what happens when pressing ctrl-alt-del, see
    ;; ctrlaltdel(8).
    (sigaction SIGINT
      (lambda _
        (stop root-service)))

    ;; Ignore SIGPIPE so that we don't die if a client closes the connection
    ;; prematurely.
    (sigaction SIGPIPE SIG_IGN)

    (if (not socket-file)
	;; Get commands from the standard input port.
        (process-textual-commands (current-input-port))
        ;; Process the data arriving at a socket.
        (let ((sock   (open-server-socket socket-file))

              ;; With Guile <= 2.0.9, we can get a system-error exception for
              ;; EINTR, which happens anytime we receive a signal, such as
              ;; SIGCHLD.  Thus, wrap the 'accept' call.
              (accept (EINTR-safe accept)))

          ;; Possibly write out our PID, which means we're ready to accept
          ;; connections.  XXX: What if we daemonized already?
          (match pid-file
            ((? string? file)
             (with-atomic-file-output pid-file
               (cute display (getpid) <>)))
            (#t (display (getpid)))
            (_  #t))

          (let next-command ()
            (match (accept sock)
              ((command-source . client-address)
               (setvbuf command-source _IOFBF 1024)
               (process-connection command-source))
              (_ #f))
            (next-command))))))

(define (process-connection sock)
  "Process client connection SOCK, reading and processing commands."
  (catch 'system-error
    (lambda ()
      (match (read-command sock)
        ((? shepherd-command? command)
         (process-command command sock))
        (#f                                    ;failed to read a valid command
         #f))

      ;; Currently we assume one command per connection.
      (false-if-exception (close sock)))
    (lambda args
      ;; Maybe we got EPIPE while writing to SOCK, or something like that.
      (false-if-exception (close sock)))))

(define %not-newline
  (char-set-complement (char-set #\newline)))

(define (process-command command port)
  "Interpret COMMAND, a command sent by the user, represented as a
<shepherd-command> object.  Send the reply to PORT."
  (match command
    (($ <shepherd-command> the-action service-symbol (args ...) dir)

     ;; We have to catch `quit' so that we can send the terminator
     ;; line to herd before we actually quit.
     (catch 'quit
       (lambda ()
         (define message-port
           (with-fluids ((%default-port-encoding "UTF-8"))
             (open-output-string)))

         (define (get-messages)
           (string-tokenize (get-output-string message-port)
                            %not-newline))

         (parameterize ((%current-client-socket message-port))
           (guard (c ((service-error? c)
                      (write-reply (command-reply command #f
                                                  (condition->sexp c)
                                                  (get-messages))
                                   port)))

             (define result
               (with-directory-excursion dir
                 (case the-action
                   ((start) (apply start service-symbol args))
                   ((stop) (apply stop service-symbol args))
                   ((enforce) (apply enforce service-symbol args))

                   ;; Actions which have the semantics of `action' are
                   ;; handled there.
                   (else (apply action service-symbol the-action args)))))

             (write-reply (command-reply command result #f (get-messages))
                          port))))
       (lambda (key)
         ;; Most likely we're receiving 'quit' from the 'stop' method of
         ;; ROOT-SERVICE.  So, if we're running as 'root', just reboot.
         (if (zero? (getuid))
             (begin
               (local-output "Rebooting...")
               (reboot))
             (quit)))))
    (_
     (local-output "Invalid command."))))

(define (process-textual-commands port)
  "Process textual commands from PORT.  'Textual' means that they're as you
would write them on the 'herd' command line."
  (let loop ((line (read-line port)))
    (if (eof-object? line)

        ;; Exit on `C-d'.
        (stop root-service)

        (begin
          (match (string-tokenize line)
            ((action service arguments ...)
             (process-command (shepherd-command (string->symbol action)
                                                (string->symbol service)
                                                #:arguments arguments)
                              port))
            (_
             (local-output "invalid command line" line)))
          (loop (read-line port))))))
