(define-module (codemac clamp)
  #:export clamp)

(define (clamp arg min-arg max-arg)
  (min (max arg min-arg) max-arg))
