#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd binge) main)" -s "$0" "$@"
!#
(define-module (codemac cmd binge)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2))

(define (lsdir dir)
  (filter (lambda (x) (not (or (equal? x ".")
			       (equal? x "..")))) (scandir dir)))

(define (run-exec-with-dir dir args)
  (let ((cwd (getcwd)))
    (chdir dir)
    (let ((retval 
	   (zero? (status:exit-val (apply system* args)))))
      (chdir cwd)
      retval)))

;; first we see if there is only one backlight driver,
(define *uri-paths*
  `(("https://(www.)?youtu(\.be|be\.com)/.*" . ,dl-youtube)
    ("https://arxiv\.org/.*" . ,dl-arxiv)
    ("https://.*" . ,dl-web)))

;; execs youtube-dl, returns files to copy
(define (dl-youtube uri dir)
  (if (run-exec-with-dir dir `("youtube-dl" "-f" "best" uri))
   (lsdir dir)
   #f))

;; swaps the /abs/ url with /pdf/ and downloads
(define (dl-arxiv uri dir))

;; does something to download the html
(define (dl-web uri dir))

(define (match-uri regex uri)
  (string-match regex uri))

;; matches urls to their dl func
(define (match-uri-to-dl uri)
  (define (match-uri-to-dl-tco uri url-paths)
    (if (match-uri (caar url-paths) uri)
	(cdar url-paths)
	(match-uri-to-dl-tco uri (cdr url-paths))))
  (match-uri-to-dl-tco uri *url-paths*))


(define (downloader dler uri dir)
  
  )


(define (main arg0 . args)
  (case (length args)
    ((4) (print-result (bisect (string->number (list-ref args 1))
			       (string->number (list-ref args 2))
			       (cadddr args))))
    (else (usage))))
