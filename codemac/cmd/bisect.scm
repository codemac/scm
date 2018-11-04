#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd bisect) main)" -s "$0" "$@"
!#
(define-module (codemac cmd bisect)
  #:use-module (ice-9 format)
  #:use-module (ice-9 pretty-print)
  #:use-module (srfi srfi-1))

(define (usage)
  (display "bisect <num1> <num2> <cmd w/$H for hypothesis>")
  (newline)
  (display "example: bisect 0 44 'cmd $H > $H.log'")
  (newline))

(define (refine a b)
  (truncate-quotient (+ a b) 2))

;; returns 'ok or 'notok
(define (experiment hypothesis cmd)
  (let ((res (apply system*
		    (list "rc" "-c"
			  (string-append (format #f "H=~d " hypothesis) cmd)))))
    (if (= 0 (status:exit-val res))
	'ok
	'notok)))

(define (negate var)
  (case var
    ((ok) 'notok)
    ((notok) 'ok)))

(define (bisect loarg hiarg cmd)
  (define (bisect-iter lo hi val acc)
    (if (>= lo hi)
	(cons (cons (negate val) lo) acc)
	(let* ((hypo (refine lo hi))
	       (res (experiment hypo cmd)))
	  (if (eq? val res)
	      (bisect-iter (+ hypo 1) hi val (cons (cons res hypo) acc))
	      (bisect-iter lo hypo val (cons (cons res hypo) acc))))))
  (let* ((lo (min loarg hiarg))
	 (hi (max loarg hiarg))
	 (lores (experiment lo cmd))
	 (hires (experiment hi cmd)))
    (if (eq? lores hires)
	(cons (cons lores lo) (cons hires hi))
	(bisect-iter lo hi lores '()))))

(define (print-result ls)
  (let ((toptwo (take ls 2))
	(rest (cdr ls)))
    (format #t "Run History:~%")
    (pretty-print rest)
    (format #t "~%~%Result:~%~s~%" toptwo)))

(define (main args)
  (case (length args)
    ((4) (print-result (bisect (string->number (list-ref args 1))
			       (string->number (list-ref args 2))
			       (cadddr args))))
    (else (usage))))
