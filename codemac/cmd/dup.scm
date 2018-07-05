#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd dup) main)" -s "$0" "$@"
!#
(define-module (codemac cmd dup)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 ftw)
  #:use-module (codemac util))

(define *file-hash* (make-hash-table 10240))

;; would love to get rid of sha1sum usage
(define (process-file filename statinfo flag)
  (if (not (equal? flag 'regular))
      #t
      (let* ((op (open-pipe* OPEN_READ "sha1sum" filename))
	     (sha (string-split (car (read-lines-port op)) #\space)))
	(close-pipe op)
	(if (= (length sha) 3)
	    (begin
	      (let* ((sha (car sha))
		     (res (hash-ref *file-hash* sha)))
		(if res
		    (hash-set! *file-hash* sha (append res (list filename)))
		    (hash-set! *file-hash* sha (list filename))))))
	#t)))

(define (print-results)
  (for-each
   (lambda (x)
     (format #t "dup => ~a~%" (car x))
     (for-each
      (lambda (x)
	(format #t "       ~a~%" x))
      (cadr x)))
   (filter
    list?
    (hash-map->list
     (lambda (k v) (if (> (length v) 1) (list k v) #f)) *file-hash*))))

(define (main args)
  (let ((dir (if (> (length args) 1) (cadr args) (getcwd))))
    (ftw dir process-file))
  (print-results))
