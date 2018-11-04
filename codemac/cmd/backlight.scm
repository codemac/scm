#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd backlight) main)" -s "$0" "$@"
!#
(define-module (codemac cmd backlight)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-2))

(use-modules (ice-9 ftw) (ice-9 rdelim) (srfi srfi-2))
;; first we see if there is only one backlight driver,

(define *sys-bl-path* "/sys/class/backlight/")

(define (scandir-nodots dir)
  (filter (lambda (x) (not (string-prefix? "." x))) (scandir dir)))

(define (backlight-get-max bl)
  (and-let* ((inf (open-input-file (string-append *sys-bl-path* bl "/max_brightness")))
	     (s (read-string inf))
	     ((close-port inf)))
    (string->number (string-trim-both s))))

(define (backlight-get-cli bl)
  (format #t "~a: ~a%~%" bl (floor-quotient (* 100 (backlight-get bl)) (backlight-get-max bl))))

(define (backlight-get bl)
  (and-let* ((inf (open-input-file (string-append *sys-bl-path* bl "/brightness")))
	     (s (read-string inf))
	     ((close-port inf)))
    (string->number (string-trim-both s))))

(define (backlight-get-percentage bl val)
  (floor-quotient
   (* (string->number (string-trim-right val #\%))
      (backlight-get-max bl))
   100))

(define (calc-percent x max)
  (floor-quotient (* x max) 100))

(define (raw-add x cur blmax bl)
  (backlight-write bl (min (+ cur x) blmax)))

(define (raw-sub x cur blmax bl)
  (backlight-write bl (max (- cur x) 0)))

(define (percent-add x cur blmax bl)
  (backlight-write bl (min (+ cur (calc-percent x blmax)) blmax)))

(define (percent-sub x cur blmax bl)
  (backlight-write bl (max (- cur (calc-percent x blmax)) 0)))

(define (percent-absolute x cur blmax bl)
  (backlight-write bl (calc-percent x blmax)))

(define (raw-absolute x cur max bl)
  (backlight-write bl x))

(define (arg-mode val)
  (let* ((percentage (string-suffix? "%" val))
	 (sub (if percentage percent-sub raw-sub))
	 (add (if percentage percent-add raw-add)))
    (cond
     ((string-prefix? "-" val) sub)
     ((string-prefix? "+" val) add)
     (percentage percent-absolute)
     (else
      raw-absolute))))

;; given +10% -> add
(define (backlight-set bl val)
  (let* ((mode (arg-mode val))
	 (bl-cur (backlight-get bl))
	 (bl-max (backlight-get-max bl))
	 (num (string-trim-both val (char-set #\% #\+ #\- #\space))))
    (mode (string->number num) bl-cur bl-max bl)))

(define (backlight-write bl val)
  (and-let* ((outf (open-output-file (string-append *sys-bl-path* bl "/brightness")))
	     ((display val outf)))
    (format #t "~a~%" val)))

(define (usage)
  (format #t "backlight <set|get> [delta][percent] [backlight name]~%"))

(define (action name val backlight)
  (case (string->symbol name)
    ((get) (backlight-get-cli backlight))
    ((set) (backlight-set backlight (val)))
    (else (usage))))

(define (get-backlight ls args)
  (if (> (length ls) 1)
      (car (last-pair args))
      (car ls)))

(define (main args)
  (let* ((ls (scandir-nodots *sys-bl-path*))
	 (bl (get-backlight ls args)))
    (if (= (length args) 1)
	(action "get" identity bl)
	(action (list-ref args 1)
		(lambda () (list-ref args 2))
		bl))))

