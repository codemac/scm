#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd retire) main)" -s "$0" "$@"
!#
(define-module (codemac cmd retire)
  #:use-module (codemac monte-carlo)
  #:use-module (ice-9 pretty-print)
  #:use-module (srfi srfi-1))

(define (simulation)
  (let* ((years-lived (random-uniform #:min 50 #:max 100))
	 (retirement-years (- years-lived 34))
	 (return-rates (random-normal-list #:length retirement-years #:mean 0.07 #:stdev 0.09))
	 (final-val (fold (lambda (x prev) (+ prev (* x prev))) 100000 return-rates)))
    `((years-lived . ,years-lived)
      (retirement-years . ,retirement-years)
      (return-rates . ,return-rates)
      (final-val . ,final-val))))

(define (main arg0 . args)
  (pretty-print (simulation)))
