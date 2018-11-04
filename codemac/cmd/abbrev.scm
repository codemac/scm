#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd abbrev) main)" -s "$0" "$@"
!#
(define-module (codemac cmd abbrev)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2))

(define (main args)
  )

