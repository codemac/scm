#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd org-checks-to-tasks) main)" -s "$0" "$@"
!#
(define-module (codemac cmd org-checks-to-tasks)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:use-module (ice-9 rdelim)
  #:use-module (rx irregex))

(define (curry f . rest)
  (lambda args
    (apply f (append rest args))))

(define *ordered* #f)

(define (read-entry-lines iport)
  (define (tco iport acc)
    (let ((ln (read-line iport)))
      (if (eof-object? ln)
	  acc
	  (tco iport (append acc (list ln))))))
  (tco iport '()))

(define all-stars?
  (lambda (lst)
    (reduce
     (lambda (a b)
       (and b (eq? #\* a)))
     #t
     lst)))

(define list-stars
  (lambda (lst)
    (if (> 1 (length lst))
	(list 0)
	(fold
	 (lambda (x y)
	   (if (and (eq? x #\space)
		    (all-stars? y))
	       (list (length y))
	       (cons x y)))
	 '()
	 lst))))

(define (checkbox->orgtask line)
  (irregex-match)
  (let ((thelst (string->list line)))
    (define (tco lst)
      (cond
       ((null? lst) '())
       ((equal? (car lst) #\-)
	(tco (cdr lst)))
       ((equal? (car lst) #\space)
	(tco (cdr lst)))
       ())
      )
))
(define (count-stars line)
  (let* ((slist (string->list line))
	 (foldres (list-stars slist)))
      (car (last-pair foldres))))

(define (org-header? line)
  (irregex-search '(: bol (+ "*") " ") line))

(define (org-checkbox? line)
  (irregex-search '(: (* whitespace) "-" (+ whitespace) "[" (* (or "X" " ")) "] ") line))

(define (combine-lines lst)
  (fold
   (lambda (x y)
     (if (> (string-length y) 0)
	 (string-append y "\n" x)
	 x))
   ""
   lst))

(define (remunge-entities lst)
  (define (tco l acc curset)
    (if (= 0 (length l))
	(append acc (list (combine-lines curset)))
	(let ((nextl (car l)))
	  (cond
	   ((equal? "" nextl)
	    (tco (cdr l) (append acc (list (combine-lines curset))) '()))
	   ((org-checkbox? nextl)
	    (tco (cdr l) (append acc (list (combine-lines curset))) (list nextl)))
	   (else
	    (tco (cdr l) acc (append curset (list nextl))))))))
  (tco lst '() '()))

(define (filter-checkboxes lst)
  (filter org-checkbox? lst))

(define (make-org-entry nstars title)
  
  (format #f ""))

(define (remove-beginning-blanks lst)
  (cond
   ((null? lst) '())
   ((irregex-match '(: bol (* whitespace) eol) (car lst))
    (remove-beginning-blanks (cdr lst)))
   (else lst)))

(define (remove-properties thelst)
  (define (tco lst acc level)
    (cond
     ((null? lst) acc)
     ((irregex-match '(: bol (* whitespace) (or ":PROPERTIES:" ":LOGBOOK:") (* whitespace) eol) (car lst))
      (tco (cdr lst) acc (1+ level)))
     ((irregex-match '(: bol (* whitespace) ":END:" (* whitespace) eol) (car lst))
      (tco (cdr lst) acc (1- level)))
     ((= level 0)
      (tco (cdr lst) (append acc (list (car lst))) 0))
     (else
      (tco (cdr lst) acc level))))
  (tco thelst '() 0))

(define (main args)
  (and-let*
      ((entries (remove-beginning-blanks (read-entry-lines (current-input-port))))
       ((org-header? (car entries)))
       ((format #t "entries: ~s~%" entries))
       (nstars (count-stars (car entries)))
       ((format #t "nstars: ~s~%" nstars))
       (no-props (remove-properties (cdr entries)))
       ((format #t "no-props: ~s~%" no-props))
       (rent (remunge-entities no-props))
       ((format #t "rent: ~s~%" rent)))
    (format #t "~s~%" (filter-checkboxes rent))))
