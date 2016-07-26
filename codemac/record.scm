(define-module (codemac record)
  #:export (define-record-all))

(define-syntax define-record-all
  (syntax-rules ()
    (_ name (constructor field field*))))


