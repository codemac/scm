#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd mail-sync) main)" -s "$0" "$@"
!#
(define-module (codemac cmd mail-sync)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2))

(define mailsync-cmd '("mbsync" "-a"))
(define notmuch-index-cmd '("notmuch" "new"))
(define notmuch-tag-cmd '("notmuch" "tag"))

;; TODO: when guile can be assuredly 2.1+ on any system I run on (so
;; in a few years?) replace this with a native guile-fibers
;; implementation.
(define (timelimit-exec args)
  (define timelimitargs '("timelimit" "-q" "-p" "-T" "5" "-t" "300"))
  (zero? (status:exit-val (apply system* (append timelimitargs args)))))

;; An alist of pairs, string of search parameters, and a string of tag
;; parameters to notmuch
(define notmuch-tag-order
  '((("tag:new" "and" "tag:unread")
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
    (("tag:new")
     . ("-new"))))

(define (pull-mail)
  (timelimit-exec mailsync-cmd))

(define (notmuch-index)
  (timelimit-exec notmuch-index-cmd))

(define (notmuch-tag)
  (reduce
   (lambda (x y) (and x y)) #t 
   (map
    (lambda (x)
      (let ((search-term (car x))
	    (tag-term (cdr x)))
	(timelimit-exec (append notmuch-tag-cmd
				tag-term
				'("--")
				search-term))))
    notmuch-tag-order)))

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
