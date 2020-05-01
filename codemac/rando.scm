(set! *random-state* (seed->random-state (current-time)))
(define* (random-value #:key (min 0.0) (max 1.0))
  (lambda _ (+ (random (- max min)) min)))

(define* (constant-value val)
  (lambda _ val))

(define *monthly-spend* (constant-value 1000))
(define *withdrawl-rate* (constant-value 0.04))
(define *current-year* (+ 1900 (tm:year (localtime (current-time)))))
(define *years-of-retirement* (constant-value (- 2085 *current-year*)))
(define *growth-rate* (random-value #:min -0.04 #:max 0.2))

;; single simulation

(define (repeated func num startargs)
  (if (= num 0)
      startargs
      (func (repeated func (- num 1) startargs))))

(define (month-action total)
  (let* ((new-tot (* total (+ 1 (/ (*growth-rate*) 12))))
	 (withdrawn (* new-tot (/ (*withdrawl-rate*) 12)))
	 (spent (*monthly-spend*)))
    (- new-tot spent)))

(format #t "~s\n" (repeated month-action (* 12 (*years-of-retirement*)) 1000000))

