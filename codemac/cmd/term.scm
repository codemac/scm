#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd term) main)" -s "$0" "$@"
!#
(define-module (codemac cmd term)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 format)
  #:use-module (codemac util))

(define *rs* (random-state-from-platform))

(define* (generate-rand-color #:key (min 0) (max 30))
  (define (gen-color)
    (+ (random (- max min) *rs*) min))
  (let ((rr (gen-color))
	(gr (gen-color))
	(br (gen-color)))
    (format #f "#~2,'0x~2,'0x~2,'0x" rr gr br)))

(define (main arg0 . args)
  (execlp "uxterm" "uxterm" "-bg" (generate-rand-color)))