#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd tmux-window-title) main)" -s "$0" "$@"
!#
(define-module (codemac cmd tmux-window-title))

(define (command-map cmd path)
  (cond
   ((string=? cmd "google-emacs")
    (list "emacs" (path-map path)))
   ((string=? cmd "weechat-curses")
    (list "irc"))
   ((string=? cmd "rc")
    (list "rc" (path-map path)))
   (else
    (list cmd (path-map path)))))

(define (get-workspace-name path)
  (let ((paths (filter (lambda (x) (not (string-null? x))) (string-split path #\/))))
    (car (list-tail paths (- (length paths) 2)))))

(define (path-map path)
  (cond
   ((string-suffix? "google3" path)
    (get-workspace-name path))
   (else
    (basename path))))

(define (main args)
  (let ((title (command-map (cadr args) (caddr args))))
    (display (string-concatenate (list (car title) " " (cadr title) "\n")))))

