#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd timezip) main)" -s "$0" "$@"
!#
(define-module (codemac cmd timezip)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2)
  #:use-module (web client)
  #:use-module (rnrs bytevectors)
  #:use-module (codemac vendor irregex))

(define *ext-ip-cmd* '("dig" "+short" "myip.opendns.com" "@resolver1.opendns.com"))

(define (current-external-ip)
  (and-let* ((p (apply open-pipe* OPEN_READ *ext-ip-cmd*))
	     (l (read-line p))
	     (zero? (close-pipe p)))
    l))

(define (current-tz ip)
  (and-let* ((apinfo
	      (call-with-values
		  (lambda _ (http-get (string-append "http://ip-api.com/json/" ip)))
		(lambda (_ x) (utf8->string x))))
	     (rxres (irregex-extract '(: "\"timezone\"" (* whitespace) ":" (* whitespace) "\"" (+ (or "/" alphanumeric "_")) "\"") apinfo))
	     (cleaned (string-trim-both (cadr (string-split (car rxres) #\:)) #\")))
    cleaned))

(define (main args)
  (let ((curtz (current-tz (current-external-ip))))
    (if (and (> (length args) 1)
	     (string= "set" (cadr args)))
	(begin
	  (format #t "Timezone Found ~a~%Setting...~%" curtz)
	  (exit (status:exit-val (system* "sudo" "timedatectl" "set-timezone" curtz))))
	(format #t "Timezone Found: ~a~%" curtz))))
