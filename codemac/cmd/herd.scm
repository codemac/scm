#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd herd) main)" -s "$0" "$@"
!#
(define-module (codemac cmd herd)
  #:use-module (shepherd scripts herd))

(define (main . args)
  (apply (@ (shepherd scripts herd) main) (cdr (command-line))))
