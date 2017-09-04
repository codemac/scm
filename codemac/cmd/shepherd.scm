#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd shepherd) main)" -s "$0" "$@"
!#
(define-module (codemac cmd shepherd)
  #:use-module (shepherd))

(apply main (cdr (command-line)))
