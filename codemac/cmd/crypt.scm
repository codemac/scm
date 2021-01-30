#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd crypt) main)" -s "$0" "$@"
!#
(define-module (codemac cmd crypt)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2))

(define *cmd-encrypt* (list "gpg" "--symmetric" "--armor" "--no-symkey-cache" "--cipher-algo" "AES256"))
(define *cmd-decrypt* (list "gpg" "--decrypt"))

(define (run-cmd cmd)
  (zero? (status:exit-val (apply system* cmd))))

(define (gpg-decrypt-file fn)
  (run-cmd (append *cmd-decrypt* (list fn))))

(define (gpg-encrypt-file fn)
  (run-cmd (append *cmd-encrypt* (list fn))))

(define (encrypt-or-decrypt-file fn)
  (cond
   ((string-suffix-ci? ".asc" fn) (gpg-decrypt-file fn))
   (else (gpg-encrypt-file fn))))

(define (main args)
  (map encrypt-or-decrypt-file (cdr args)))
