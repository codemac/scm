#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd uniqc) main)" -s "$0" "$@"
!#
(define-module (codemac cmd uniqc)
  #:use-module (codemac util))

;; input:
;; uniq -c output
;; output:
;; ("string" . cnt)

(define (convert-line s)
  (string-split s ))
(define (main . args)
  (map-lines-port (current-input-port) )
  )
