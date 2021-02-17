#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd missing-numbers) main)" -s "$0" "$@"
!#
(define-module (codemac cmd missing-numbers))

(define (main args)
  (let ((directory-contents (scandir (cadr args))))
    
    )
  
  )
