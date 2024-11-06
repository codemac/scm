#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd orgparse-test) main)" -s "$0" "$@"
!#

(define-module (codemac cmd orgparse-test)
  #:use-module (ice-9 textual-ports)
  #:use-module (codemac orgparse)
  #:use-module (ice-9 peg)
  #:use-module (ice-9 pretty-print)
  #:use-module (system vm trace))

(define (display-peg-tree contents)
  (pretty-print (peg:tree (orgparse-tree contents))))

(define (main args)
  (call-with-input-file (cadr args)
    (lambda (port) (display-peg-tree (get-string-all port)))))
