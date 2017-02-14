#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd jailed) main)" -s "$0" "$@"
!#

;; jailed runs a command in a chroot jail, and lets you populate the
;; following ways:
;; - bind mount (map things into it like /dev)
;; - command output (run a series of commands to files)
;; - static content (provided content for specific files)
;;
;; you can get data *out* of the jail at command completion time:
;; - specify which files to copy out and to where
;; - disable jail cleanup

(define-module (codemac cmd jailed))

; 
(define (main args)
  
  )
