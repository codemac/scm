#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd herd) main)" -s "$0" "$@"
!#
(define-module (codemac cmd herd)
  #:use-module (shepherd scripts herd))

(apply main (cdr (command-line)))
