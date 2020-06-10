(define-module (codemac monte-carlo)
  #:export (random-uniform random-normal random-normal-list random-exp monte-carlo:*rs*))

(define monte-carlo:*rs* (seed->random-state (cdr (gettimeofday))))

(define* (random-uniform #:key (min 0.0) (max 1.0))
  (+ (random (- max min) monte-carlo:*rs*) min))

(define* (random-normal #:key (mean 0.0) (stdev 1.0))
  (+ mean (* stdev (random:normal monte-carlo:*rs*))))

(define* (random-normal-list #:key (length 10) (mean 0.0) (stdev 1.0))
  (let ((v (make-vector length)))
    (random:normal-vector! v monte-carlo:*rs*)
    (map (lambda (e) (+ mean (* stdev e))) (vector->list v))))

(define* (random-exp #:key (mean 0.0))
  (* mean (random:exp monte-carlo:*rs*)))


