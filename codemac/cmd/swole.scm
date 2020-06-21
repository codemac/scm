#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd swole) main)" -s "$0" "$@"
!#
(define-module (codemac cmd swole)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 pretty-print)
  #:use-module (srfi srfi-2))

(define (simple-calorie-count complete-body-mass-lbs hours-formal-exercise)
  "Simple calorie count calculation, based on exercise and body mass in lbs.

  Uses a simple algorithm from bro science. Decent accuracy for folks
  with hard to calculate RMR."
  (* complete-body-mass-lbs
     (cond
      ((> hours-formal-exercise 6) 12)
      ((> hours-formal-exercise 3) 11)
      (else 10))))

(define (lean-body-mass-lbs total-body-weight-lbs body-fat-pct)
  (* total-body-weight-lbs (- 1 body-fat-pct)))

(define (resting-metabolic-rate lean-body-mass-lbs)
  (+ 370 (* 9.7976 lean-body-mass-lbs)))

(define (activity-rate-multiple weekly-hours)
  (+ (* (/ 2 30) weekly-hours) (/ 51 45)))

(define (complex-calorie-count total-body-weight-lbs body-fat-pct weekly-hours)
  (* (activity-rate-multiple weekly-hours)
     (resting-metabolic-rate
      (lean-body-mass-lbs total-body-weight-lbs body-fat-pct))))

(define (male-target-deficit body-fat-pct)
  (cond
   ((< body-fat-pct 0.2) 0.2)
   ((< body-fat-pct 0.3) body-fat-pct)
   (else 0.3)))

(define (female-target-deficit body-fat-pct)
  (cond
   ((< body-fat-pct 0.2) 0.2)
   ((< body-fat-pct 0.3) body-fat-pct)
   (else 0.3)))

(define (shredding-caloric-target total-body-weight body-fat-pct weekly-hours gender)
  (* (complex-calorie-count total-body-weight body-fat-pct weekly-hours)
     (- 1
	((if (eq? 'male gender)
	     male-target-deficit
	     female-target-deficit)
	 body-fat-pct))))

(define (protein-grams-per-lb weekly-hours)
  (cond
   ((< weekly-hours 3) 0.7)
   ((> weekly-hours 6) 1.1)
   (else 0.9)))

(define (protein-cals total-body-weight body-fat-pct weekly-hours)
  (* 4 (protein-grams-per-lb weekly-hours) total-body-weight (- 1 body-fat-pct)))


(define (fat-grams-per-lb)
  0.3)

(define (fat-cals total-body-weight body-fat-pct)
  (* 9 (fat-grams-per-lb) total-body-weight (- 1 body-fat-pct)))

(define (carb-cals protein-cals fat-cals total-cals)
  (- total-cals protein-cals fat-cals))

(define (vegan-shredding-stats total-body-weight
			       body-fat-pct
			       weekly-hours
			       gender)
  (let* ((total-cals (shredding-caloric-target total-body-weight body-fat-pct weekly-hours gender))
	 (protein-cals (protein-cals total-body-weight body-fat-pct weekly-hours))
	 (fat-cals (fat-cals total-body-weight body-fat-pct))
	 (carb-cals (carb-cals protein-cals fat-cals total-cals)))
    
    `((total-cals . ,total-cals)
      (protein-cals . ,protein-cals)
      (fat-cals . ,fat-cals)
      (carb-cals . ,carb-cals))))

(define (main args)
  (pretty-print `((bob . ,(vegan-shredding-stats 200.1 0.3 4 'male))
		  (sally . ,(vegan-shredding-stats 150 0.25 6 'female)))))

