(define-module (codemac bayes)
  #:export bayes-a-given-b)

(define (bayes-a-given-b b-given-a pa pb)
  (/ (* b-given-a pa) pb))



