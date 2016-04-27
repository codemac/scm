#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd review) main)" -s "$0" "$@"
!#

(define-module (codemac cmd review)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-19)
  #:use-module (rnrs io simple)
  #:use-module (rnrs io ports)
  #:use-module (ice-9 regex))

(define-record-type <org-task>
  (make-org-task title state tags meta dates content)
  org-task?
  (title org-task-title set-org-task-title!)
  (state org-task-state set-org-task-state!)
  (tags org-task-tags set-org-task-tags!)
  (meta org-task-meta set-org-task-meta!)
  (dates org-task-dates set-org-task-dates!)
  (content org-task-content set-org-task-content!))

(define (org-parse-date line)
  (let ((m (string-match "[0-9]+-[0-9]+-[0-9]+ [A-Za-z]+ [0-9]*:[0-9]*" line)))
    (string->date (match:substring m)
		  "~Y-~m-~d ~a ~H:~M")))

(define (org-parse-state line)
  (let ((m (string-split line #\")))
    `(state . (,(list-ref m 1)  ,(org-parse-date (list-ref m 4))))))

(define (org-parse-title-state line)
  (cond
   ((string-match "\\* TODO" line)
    'todo)
   ((string-match "\\* DONE" line)
    'done)
   ((string-match "\\* NVM" line)
    'nvm)
   ((string-match "\\* NEXT" line)
    'next)
   ((string-match "\\* STARTED" line)
    'started)
   ((string-match "\\* MAYBE" line)
    'maybe)
   (else
    #f)))

(define (org-parse-title line)
  (make-org-task line (org-parse-title-state line) '() '() '() ""))

(define (org-tasks-from-port p)
  (do ((line (get-line p) (get-line p))
       (org-tasks '())
       (curtask #f)
       (metastate #f))
      ((eof-object? line)
       (if (not (equal? curtask #f))
	   (append org-tasks (list curtask))
	   org-tasks))
    (cond
     ((string-match "^\\*" line)
      (if (not (equal? curtask #f))
	  (set! org-tasks (append org-tasks (list curtask))))      
      (set! curtask (org-parse-title line))
      (set! metastate #t))
     (else 
      (cond
       ((and (string-match "^[ \t]*$" line)
	     (not (equal? #f curtask)))
	(set! org-tasks (append org-tasks (list curtask)))
	(set! curtask #f)
	(set! metastate #f))
       (metastate
	(cond
	 ((string-match ".*CLOSED.*" line)
	  (let ((d (org-parse-date line)))
	    (set-org-task-meta! curtask (append (org-task-meta curtask) (list `(closed . ,d))))))
	 ((string-match "- State .*" line)
	  (set-org-task-meta! curtask (append (org-task-meta curtask) (list (org-parse-state line))))))))))))

(define (org-file-tasks file)
  (org-tasks-from-port (open-file-input-port file)))

(define (org-task-archived ot)
  (set-org-task-state! ot 'archived))

(define (org-archive-file-tasks file)
  (map org-task-archived (org-file-tasks file)))

(define (eq-one elt ls)
  (reduce (lambda (x y) (or x y)) #f
	  (map (lambda (x) (eq? x elt)) ls)))

(define (org-is-completed elt)
  (eq-one (org-task-state elt) '(done nvm)))

(define (task-closetime ot)
  (car (filter (lambda (x) (not (eq? x #f)))
	       (map (lambda (x)
		      (if (eq? (car x) 'closed)
			  (cdr x)
			  #f))
		    (org-task-meta ot)))))

(define (task-in-a-day ot)
  (let ((tc (task-closetime ot))
	(cd (localtime (- (current-time) 86400))))
    (set-tm:hour cd 0)
    (set-tm:min cd 0)
    (set-tm:sec cd 0)
    (car (mktime cd))
    ))

;; - Review all things marked "done" yesterday
(define (org-done-yesterday? ot)
  (and (org-is-completed ot)
       (task-in-a-d)
       )
  )

(define (review-done-yesterday)
  (filter org-done-yesterday? (org-file-tasks (string-append (getenv "HOME") "/org/gtd.org")))
  )

  ;; - Review Calendar yesterday, today, tomorrow
  ;; - Process personal email inbox
  ;; - Process work email inbox
  ;; - Process mobile inbox
  ;; - Process org-mode inbox
  ;; - Schedule time for important tasks in the day



;; this should email me a form of some type, in text form daily
(define (review-daily)
  ;; - Review all things marked "done" yesterday
  
  ;; - Review Calendar yesterday, today, tomorrow
  ;; - Process personal email inbox
  ;; - Process work email inbox
  ;; - Process mobile inbox
  ;; - Process org-mode inbox
  ;; - Schedule time for important tasks in the day
  #t
  )

(define (main args)
  (map (lambda (x) (format #t "~s~%" (org-task-title x))) (org-tasks-from-port (open-input-file "/home/jmickey/org/gtd.org"))))
