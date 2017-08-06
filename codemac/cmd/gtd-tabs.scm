#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd gtd-tabs) main)" -s "$0" "$@"
!#
(define-module (codemac cmd gtd-tabs)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2)
  #:use-module (json))

;; TODO: have it dynamically look this up!
(define *recovery-js* (string-append
		       (getenv "HOME")
		       "/.mozilla/firefox/znbrv8eh.default/sessionstore-backups/recovery.js"))


;; json structure for tabs:
;;                                     entries : <array> : pinned = true
;;                                     entries : <array> : index - 1 = array index of cur tab
;; windows: <array> : tabs : <array> : entries : <array> : {url: title: }


(define (firefox-json)
  (with-input-from-file *recovery-js*
    (json->scm)))

(define (firefox-tabs)
  (let ((json (firefox-json)))
    ()
    
    )
)

(define (main . args))
