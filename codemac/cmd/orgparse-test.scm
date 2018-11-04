#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd orgparse-test) main)" -s "$0" "$@"
!#

(define-module (codemac cmd orgparse-test)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 peg)
  #:use-module (ice-9 pretty-print)
  #:use-module (system vm trace))

(define-peg-pattern nl none
  "\n")

(define-peg-pattern whitespace none
  (or "\n" "\t" " "))

(define-peg-pattern space none
  " ")

(define-peg-pattern blanks none
  (* space))

(define-peg-pattern stars body
  (+ "*"))

(define-peg-pattern uppercase body
  (or (range #\A #\Z)))

(define-peg-pattern lowercase body
  (or (range #\a #\z)))

(define-peg-pattern numbers body
  (or (range #\0 #\9)))

(define-peg-pattern alphanum body
  (or numbers lowercase uppercase))

(define-peg-pattern ascii body
  (or uppercase lowercase numbers
      "#"  "-"  "_"  "}"  "$"  "."  "`"  "~"  "%"  "/"  " "
      "&"  ":"  "'"  ";"  "("  "<"  ")"  "="  "["  "*"  ">"
      "\\" "!"  "+"  "?"  "]"  "{"  "\"" ","  "@"  "^"  "|"))

(define-peg-pattern tag all
  alphanum)

(define-peg-pattern tagset all
  (and ":" tag (* (and ":" tag)) ":"))

(define-peg-pattern state all
  (or "TODO"
      "NEXT"
      "STARTED"
      "WAITING"
      "DONE"
      "NVM"
      "PROJECT"))

(define-peg-pattern eof none
  (not-followed-by peg-any))

(define-peg-pattern node-body all
  (and (* (or ascii nl)) (followed-by (or (and nl stars) (and nl eof)))))

;; TODO parse clock entries!
(define-peg-pattern logbook-field body
  (* ascii))

(define-peg-pattern logbook-drawer all
  (and blanks ":LOGBOOK:" nl
       (* (and blanks logbook-field))
       blanks ":END:" nl))

(define-peg-pattern property-field body
  (and ":" uppercase ":" blanks ascii nl))

(define-peg-pattern property-drawer all
  (and blanks ":PROPERTIES:" nl
       (* (and blanks property-field))
       blanks ":END:" nl))

(define-peg-pattern drawers all
  (* (or property-drawer
	 logbook-drawer)))

(define-peg-pattern priority all
  (and "[#" uppercase "]"))

(define-peg-pattern heading all
  (and (? (and space state)) (? (and space priority)) (? (and space ascii)) (? (and space tagset))
       (? (and nl drawers))))

(define-peg-pattern node all
  (and stars heading
       (? (and nl node-body))))

(define-peg-pattern header all
  (and "#+" alphanum ":" blanks ascii nl))

(define-peg-pattern comment all
  (and "#" ascii nl))

(define-peg-pattern orgdoc all
  (and (* (or whitespace header comment)) (* node)))

(define (orgparse-tree str)
  (match-pattern orgdoc str))

(define (display-peg-tree contents)
  (format #t "~s~%" (orgparse-tree contents)))

(define (main args)
  (with-input-from-file (cadr args)
    (display-peg-tree (get-string-all (current-input-port)))))
