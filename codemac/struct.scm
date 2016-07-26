(define-module (codemac struct)
  #:use-module (srfi srfi-9)
  #:export (define-struct))

;; The form:
;; (datum->syntax
;;  #'davar
;;  (string->symbol
;;   (string-append
;;    "text"
;;    (symbol->string
;;     (syntax->datum #'davar)))))
;;
;; does the following:
;;
;; - First, place the symbol "davar" from datum back into syntax land.
;; - Then run the code, which pulls davar back out of syntax into
;; datum to transform it's name.


(define-syntax define-struct
  (lambda (x)
    (syntax-case x ()
      ((_ name f* ...)
       #`(define-record-type name
	   ;; constructor
	   (#,(datum->syntax
	       #'name
	       (string->symbol
		(string-append
		 "make-" (symbol->string (syntax->datum #'name)))))
	    f* ...)
	   
	   ;; predicate
	   #,(datum->syntax
	      #'name
	      (string->symbol
	       (string-append
		(symbol->string (syntax->datum #'name)) "?")))
	   
	   ;; field specs
	   #,@(map (lambda (f)
		     (list
		      f
		      (datum->syntax
		       #'name
		       (string->symbol
			(string-append
			 (symbol->string (syntax->datum #'name))
			 "-"
			 (symbol->string (syntax->datum f)))))
		      (datum->syntax
		       #'name
		       (string->symbol
			(string-append
			 "set-"
			 (symbol->string (syntax->datum #'name))
			 "-"
			 (symbol->string (syntax->datum f))
			 "!")))))
		   #'(f* ...)))))))
