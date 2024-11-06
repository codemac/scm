(define-module (codemac modeling)
  #:use-module (oop goops)
  #:use-module (srfi srfi-111))

;; carefull all ye who enter here, we will be using boxes! Yes, we
;; somehow have effed up and are using pointers in scheme. I will see
;; what other options there are before totally going down this path
;; though.

;; In any system model, we have queues(stacks), and inputs and
;; outputs.

(define-class <model> ()
  ;; list of outputs
  (outputs #:init-value ()
	   #:accessor model-outputs))

;; a generalized queue of a floating point number
(define-class <model-stack> ()
  (amount #:init-value 0.0
	  #:accessor model-stack-amount))

;; a generalized input/output
(define-class <model-pipe> ()
  ())
