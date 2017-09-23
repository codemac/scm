#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd mail-sync) main)" -s "$0" "$@"
!#
(define-module (codemac cmd mail-sync)
  #:use-module (codemac util)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:export (main))

(define mailsync-cmd '("mbsync" "-a"))
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
  (define timeout-args '("timeout" "-k" "10s" "10m"))
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
;
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
  (let* ((muted-threads (notmuch-retrieve-all-muted))
	 (muted-section (if (> (length muted-threads) 0)
			    `(,muted-threads . ("+muted" "-flagged" "-unread" "-inbox"))
			    '())))
    `((("tag:new" "and" "tag:unread")
       . ("+flagged" "+unread"))
      (("path:work/INBOX/**" "or" "path:cm/INBOX/**")
       . ("+inbox"))
      (("tag:new" "and" "tag:inbox")
       . ("+flagged"))
      (("from:j@codemac.net" "or" "from:jmickey@google.com")
       . ("+sent"))
      (("path:work/**")
       . ("+work"))
      (("path:cm/**")
       . ("+codemac"))
      (("not" "(" "path:work/INBOX/**" "or" "path:cm/INBOX/**" ")")
       . ("-inbox"))
      ,muted-section
      (("tag:new")
       . ("-new")))))

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

(define (pull-mail)
  (let ((res (timeout-exec mailsync-cmd)))
    (find-delete-mbsync-lockfiles)
    res))

(define (notmuch-index)
  (timeout-exec notmuch-index-cmd))

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
   pull-mail
   notmuch-index
   notmuch-tag))
