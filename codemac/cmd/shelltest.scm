#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd shelltest) main)" -s "$0" "$@"
!#
(define-module (codemac cmd shelltest)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2)
  #:use-module (scsh syntax))

(define (main args)
  (run (| (echo "hi\nthere") (grep there))))

