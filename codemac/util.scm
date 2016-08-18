(define-module (codemac util)
  #:use-module (ice-9 rdelim)
  #:export (for-each-line-port
	    for-each-line
	    map-lines-port
	    read-lines-port
	    read-lines
	    map-lines
	    fold-lines-port
	    fold-lines))

(define (for-each-line-port port proc)
  (do ((l (read-line port) (read-line port)))
      ((eof-object? l))
    (proc l)))

(define (for-each-line fn proc)
  (with-input-from-file fn
    (for-each-line-port (current-input-port) proc)))

(define (map-lines-port port proc)
  (let ((l (read-line port)))
    (if (not (eof-object? l))
	(cons (proc l) (map-lines-port port proc))
	'())))

(define (read-lines-port p)
  (map-lines-port p identity))

(define (read-lines)
  (read-lines-port (current-input-port)))

(define (map-lines fn proc)
  (with-input-from-file fn
    (map-lines-port (current-input-port) proc)))

(define (fold-lines-port port proc init)
  (define (fold-lines-port-tco por pro init acc)
    (let ((l (read-line por)))
      (if (not (eof-object? l))
	  (fold-lines-port-tco por pro (pro l acc)))))
  (fold-lines-port-tco port proc init))

;; proc here takes two arguments, left and right.
(define (fold-lines fn proc init)
  (with-input-from-file fn
    (fold-lines-port (current-input-port) proc init)))
