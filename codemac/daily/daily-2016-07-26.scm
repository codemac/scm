(use-modules (ice-9 rdelim)
	     (codemac struct))

(define-struct din word width height)

(define (read-the-input)
  (let* ((theline (read-line (current-input-port)))
	 (values (string-split theline #\space)))
    (apply make-din values)))

(define in (read-the-input))

(set-din-width! in (string->number (din-width in)))
(set-din-height! in (string->number (din-height in)))

(define (display-longline ln w h word)
  (let ((dword (if (equal? 0 (modulo ln (* 2 (1- (string-length word)))))
		  word (string-reverse word))))
    (do ((i 0 (1+ i)))
	((> i (1- w)))
      (let ((lword (if (even? i) dword (string-reverse dword))))
	(string-for-each-index
	 (lambda (si)
	   (if (and (> i 0) (equal? si 0))
	       #t
	       (format #t "~a " (string-ref lword si))))
	 lword)))))

(define (display-stilts ln w h word)
  (let ((dword (if ( (modulo (1- (string-length word))))))))
  (do ((i 0 (1+ i)))
      ((> i (1+ w)))
    ())

  )


(define (chars-high n l)
  (+ l
     (* (- 1 l) (- 1 n))
     -1))

(define (chars-wide n l)
  (+ (* 2 l)
     (* (* 2 (- 1 l)) (- 1 n))
     -1))

(do ((i 0 (1+ i)))
    ((> i (chars-high (din-height in) (string-length (din-word in)) )))
  (if (equal? 0 (modulo i (- 1 (string-length (din-word in)))))
      (begin
	(display-longline i (din-width in) (din-height in) (din-word in))
	(newline))
      (begin
	(display-stilts i (din-width in) (din-height in) (din-word in))
	(newline))))

;; 2 * 8 = 16
;; (2 * 4) + (2 * 3) - 1 = 14


;; W O R D R O W 0
;; O     R     O 1
;; R     O     R 2
;; D R O W O R D 3
;; R     O     R 4
;; O     R     O 5
;; W O R D R O W 6
