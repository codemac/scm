#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd mcron) main)" -s "$0" "$@"
!#
(define-module (codemac cmd mcron)
  #:use-module (mcron main))

(apply main (command-line))
