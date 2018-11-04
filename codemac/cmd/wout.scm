#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd wout) main)" -s "$0" "$@"
!#
(define-module (codemac cmd wout)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2))

(define (main args)
  )

