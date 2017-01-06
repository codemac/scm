#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd lips) main)" -s "$0" "$@"
!#

;; this is mostly borrowed from the lips project, as they have a bunch
;; of random hacks that we don't need for their "config"

(define-module (codemac cmd lips)
  #:use-module (lips process)
  #:use-module (lips standard))

(define (usage)
  (format #t "Usage:\t lips < input.txt > output.txt | lips input.txt output.txt~%")
  (exit 1))

(define (main args)
  (case (length args)
    ((3)
     (set-current-input-port (open-file (list-ref args 1) "r"))
     (set-current-output-port (open-file (list-ref args 2) "w")))
    ((1) '())
    (else (usage)))
  ;; why do they do this
  (use-modules (lips standard))
  (process (current-input-port) (current-output-port))
  (if (defined? 'call-finish-hooks)
      (call-finish-hooks)))
