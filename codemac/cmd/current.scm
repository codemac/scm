#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd current) main)" -s "$0" "$@"
!#
(define-module (codemac cmd current)
  #:use-module (ice-9 popen))


(define (run-stdout cmd)
  (and-let*
      ((p (apply open-pipe* `(,OPEN_READ ,@cmd)))
       (lines (read-lines-port p))
       (exitv (status:exit-val (close-pipe p))))
    (if (zero? exitv)
	lines
	#f)))

(define (xdotool-getwindowfocus)
  (car (run-stdout '("xdotool" "getwindowfocus"))))

(define (xprop-wmclass wmid)
  (let ((classtr (run-stdout `("xprop" "-id" ,wmid "WM_CLASS"))))
    (if (string-prefix? "WM_CLASS(STRING) =" (car classtr))
	(let ((parts (string-split (string-drop (car classtr) 19) #\,)))
	  (map (lambda (x) (string-trim-both x (char-set #\" #\space))) parts)))))

(define (xprop-wmname wmid)
  (let ((namestr (run-stdout `("xprop" "-id" ,wmid "WM_NAME"))))
    (if (string-prefix? "WM_NAME(STRING) = " (car namestr))
	(let ((parts (string-split (string-drop (car namestr) 18) #\,)))
	  (map (lambda (x) (string-trim-both x (char-set #\" #\space))) parts)))))

(define (xorg-window)
  (and-let* ((wmid (xdotool-getwindowfocus))
	     (wmclass (xprop-wmclass wmid))
	     (wmname (xprop-wmname wmid)))
    `((wm_class . ,(car wmclass))
      (wm_name . ,(car wmname)))))

;; grab stuff from debugging port if open
;;
;;    (string-trim (shell-command-to-string "curl -s http://0.0.0.0:9222/json/list | jq -M '[.[] | select(.type == \"page\") | select(.url != \"chrome://newtab/\")]' | jq -M '.[0] | \"[[\" + .url + \"][\" + .title + \"]]\"' | sed -r 's/^\"(.*)\"$/\\1/'"))

(define (window-chrome-info)
  (let ((json-output (run-stdout '("curl" "-s" "https://0.0.0.0:9222/json/list"))))
    ))


(define (window-firefox-info))
;; format link from title, special stuff for gmail?


(define (window-urxvt-info))
;; get current working directory of urxvt process?

(define (window-info current-win)
  (let ((wmclass (assoc 'wm_class current-win)))
    (cond
     ()
	  ))
  )


(define (main args)
  (let ((current-win (xorg-window)))
    )
  )

