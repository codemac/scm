(define-module (codemac ht))

(define (htr h . args)
  (cond
   ((= (length args) 1)
    (hash-ref h (car args)))
   ((> (length args) 1)
    (apply htr
	   `(,(hash-ref h (car args))
	     ,@(cdr args))))
   (else #f)))

(define (ht! h . args)
  (let ((first-ref (hash-ref h (car args))))
    (if (not (> (length args) 2))
	(hash-set! h (car args) (cadr args))
	(if first-ref
	    (apply ht! `(,first-ref ,@(cdr args)))
	    #f))))

(define (ht-force! h . args)
    (let ((first-ref (hash-ref h (car args))))
    (if (not (> (length args) 2))
	(hash-set! h (car args) (cadr args))
	(if first-ref
	    (apply ht-force! `(,first-ref ,@(cdr args)))
	    (begin
	      (hash-set! h (car args) (make-hash-table))
	      (apply ht-force! `(,(hash-ref h (car args)) ,@(cdr args))))))))

