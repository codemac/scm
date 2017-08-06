(define-module (codemac syslog)
  #:use-module (system foreign))

;; libc is special
(define libcsyslog (dynamic-link))


;; syslog "options" bits
(define *log-pid*    #x01)
(define *log-cons*   #x02)
(define *log-odelay* #x04)
(define *log-ndelay* #x08)
(define *log-nowait* #x10)
(define *log-perror* #x20)

;; syslog facility bits (ash == arithmetic shift)
(define *log-kern*            0)
(define *log-user*     (ash 1 3))
(define *log-mail*     (ash 2 3))
(define *log-daemon*   (ash 3 3))
(define *log-auth*     (ash 4 3))
(define *log-syslog*   (ash 5 3))
(define *log-lpr*      (ash 6 3))
(define *log-news*     (ash 7 3))
(define *log-uucp*     (ash 8 3))
(define *log-cron*     (ash 9 3))
(define *log-authpriv* (ash 10 3))
(define *log-ftp*      (ash 11 3))
;; 12-15 reserved
(define *log-local0*   (ash 16 3))
(define *log-local1*   (ash 17 3))
(define *log-local2*   (ash 18 3))
(define *log-local3*   (ash 19 3))
(define *log-local4*   (ash 20 3))
(define *log-local5*   (ash 21 3))
(define *log-local6*   (ash 22 3))
(define *log-local7*   (ash 23 3))


;; syslog priority bits
(define *log-emerg*   0)
(define *log-alert*   1)
(define *log-crit*    2)
(define *log-err*     3)
(define *log-warning* 4)
(define *log-notice*  5)
(define *log-info*    6)
(define *log-debug*   7)

;; Function: void openlog (const char *ident, int option, int
;; facility) this is mostly for renaming things
(define openlog
  (let ((f (pointer->procedure
	    void
	    (dynamic-func "openlog" libcsyslog)
	    (list '* int int))))
    (lambda* (ident #:optional (opt (list 0)) (fac (list LOG_USER)))
      (let* ((cident (string->pointer ident))
	     (copt (apply logand opt))
	     (cfac (apply logand fac)))
	(f cident copt cfac)))))

(define syslog
  (let ((f (pointer->procedure
	    void
	    (dynamic-func "syslog" libcsyslog)
	    (list int '*))))
    (lambda (level msg)
      (let* ((clevel level)
	     (cmsg (string->pointer cmsg)))
	(f clevel cmsg)))))

(define closelog
  (pointer->procedure
   void
   (dynamic-func "closelog" libcsyslog)
   (list void)))
