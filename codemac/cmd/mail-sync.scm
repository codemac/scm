#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd mail-sync) main)" -s "$0" "$@"
!#
(define-module (codemac cmd mail-sync)
  #:use-module (codemac util)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:export (main))

(define mailsync-cmd '("mbsync" "-a"))
(define mu-index-cmd '("mu" "index" "--maildir=~/mail"))
(define mu-update-emacs-cmd '("emacsclient" "-n" "-e" "(mu4e-update-index)"))
(define notmuch-index-cmd '("notmuch" "new"))
(define notmuch-tag-cmd '("notmuch" "tag"))
(define notmuch-search-cmd '("notmuch" "search"))

;; TODO: when guile can be assuredly 2.1+ on any system I run on (so
;; in a few years?) replace this with a native guile-fibers
;; implementation.
(define (no-timelimit-exec args)
  (zero? (status:exit-val (apply system* args))))

(define (find-delete-mbsync-lockfiles)
  (ftw (string-append (getenv "HOME") "/mail")
       (lambda (fn stat flag)
	 (if (and (equal? flag 'regular)
		  (string-suffix? ".lock" fn))
	     (begin
	       (format #t "Removing lockfile: ~s~%" fn)
	       (delete-file fn)
	       #t)
	     #t))))

(define (timeout-exec args)
  (define timeout-args '("timeout" "30m"))
  (let* ((res (status:exit-val (apply system* (append timeout-args args))))
	 (errstr (format #f "timeout running: errcode: ~s args: ~s~%" res (append timeout-args args))))
    (if (number? res)
	(if (zero? res)
	    #t
	    (begin
	      (format #t errstr)
	      #f))
	(begin
	  (format #t errstr)
	  #f))))

;(define (timelimit-exec args)
;  (define timelimitargs '("timelimit" "-q" "-p" "-T" "30" "-t" "600"))
;  (let ((res (status:exit-val (apply system* (append timelimitargs args)))))
;    (if (number? res)
;	(if (zero? res)
;	    #t
;	    (error "Timelimit error!"))
;	(error "Timelimit error!"))))
;
;(define timeout-exec no-timelimit-exec)

;; An alist of pairs, string of search parameters, and a string of tag
;; parameters to notmuch
(define (notmuch-tag-order)
  `((("tag:new" "and" "tag:unread")
     . ("+unread"))
    (("(" "path:work/INBOX/**" "or" "path:cm/INBOX/**" ")" "and" "-tag:archive")
     . ("+inbox"))
    (("from:j@codemac.net" "or" "from:jmickey@google.com")
     . ("+sent"))
    (("path:work/**")
     . ("+work"))
    (("path:cm/**")
     . ("+codemac"))
    (("not" "(" "path:work/INBOX/**" "or" "path:cm/INBOX/**" ")")
     . ("-inbox" "-archive"))
    (("tag:new")
     . ("-new"))))

(define (notmuch-retrieve-all-muted)
  (and-let*
      ((args `(,OPEN_READ ,@notmuch-search-cmd "--output=threads" "tag:muted"))
       (p (apply open-pipe* args))
       (lines (read-lines-port p))
       (exitv (status:exit-val (close-pipe p))))
    (if (zero? exitv)
	lines
	(begin
	  (format #t "Retrieve all failed with: ~s~%" lines)
	  #f))))

(define (notmuch-retrieve-all-archive path)
  (and-let*
      ((args `(,OPEN_READ ,@notmuch-search-cmd "--output=files" "tag:archive" "and" ,(string-append "path:" path "/INBOX/**")))
       (p (apply open-pipe* args))
       (lines (read-lines-port p))
       (exitv (status:exit-val (close-pipe p))))
    (if (zero? exitv)
	lines
	(begin
	  (format #t "Retrieve all failed with: ~s~%" lines)
	  #f))))

;; remove UID from mailpath
;; construct path given dstpath acct to archive
(define (archive-mail-message dst mailpath)
  (let* ((dstpath (string-append (getenv "HOME") "/mail/" dst "/all/cur/"))
	 (newfile (regexp-substitute/global #f ",U=[0-9]+" (basename mailpath) 'pre 'post))
	 (newpath (string-append dstpath newfile)))
    (if (and (file-exists? mailpath)
	     (not (string-prefix? dstpath mailpath)))
	(rename-file mailpath newpath)
	#t)))

(define (notmuch-archive-mail)
  (for-each
   (lambda (x)
     (for-each
      (lambda (f) (archive-mail-message x f))
      (notmuch-retrieve-all-archive x)))
   (list "work" "cm"))
  #t)

(define (pull-mail)
  (let ((res (timeout-exec mailsync-cmd)))
    (find-delete-mbsync-lockfiles)
    res))

(define (notmuch-index)
  (timeout-exec notmuch-index-cmd))

(define (mu-index)
  (timeout-exec mu-index-cmd))

(define (mu-update-emacs)
  (timeout-exec mu-update-emacs-cmd))

(define (notmuch-tag)
  (reduce
   (lambda (x y) (and x y)) #t 
   (map
    (lambda (x)
      (let ((search-term (car x))
	    (tag-term (cdr x)))
	(timeout-exec
	 (append notmuch-tag-cmd tag-term '("--") search-term))))
    (notmuch-tag-order))))

(define (run-in-order . thunks)
  (let loop ((ts thunks))
    (if (null? ts)
	#t
	(let ((next (car ts)))
	  (if (next)
	      (loop (cdr ts))
	      (begin
		(format #t "Failed to complete run at: ~s ~a" next next)
		#f))))))

(define (main . args)
  (run-in-order
   notmuch-archive-mail
   pull-mail
   notmuch-index
   notmuch-tag))

;; (define (main . args)
;;   (run-in-order
;;    pull-mail
;;    mu-update-emacs))


