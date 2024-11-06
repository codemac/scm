(define-module (codemac orgparse)
  #:use-module (rx irregex)
  #:use-module (ice-9 peg)
  #:use-module (scheme base)
  #:export (orgparse-tree
	    orgdoc))

(define-peg-pattern nl body
  "\n")

(define-peg-pattern whitespace body
  (or "\n" "\t" " "))

(define-peg-pattern space body
  " ")

(define-peg-pattern blanks body
  (* whitespace))

(define-peg-pattern star all
  "*")
(define-peg-pattern stars all
  (+ star))

(define-peg-pattern uppercase body
  (or (range #\A #\Z)))

(define-peg-pattern lowercase body
  (or (range #\a #\z)))

(define-peg-pattern numbers body
  (or (range #\0 #\9)))

(define-peg-pattern alphanum body
  (or numbers lowercase uppercase))

(define-peg-pattern ascii-colon body
  ":")

(define-peg-pattern ascii-symbols-not-colon-not-star body
  (or "#"  "-"  "_"  "}"  "$"  "."  "`"  "~"  "%"  "/"  " "
      "&"  "'"  ";"  "("  "<"  ")"  "="  "[" ">"  "\\"
      "!"  "+"  "?"  "]"  "{"  "\"" ","  "@"  "^"  "|"))

(define-peg-pattern ascii-symbols-not-colon body
  (or ascii-symbols-not-colon-not-star "*"))

(define-peg-pattern ascii-symbols-not-star body
  (or ascii-symbols-not-colon-not-star ":"))

(define-peg-pattern ascii-symbols body
  (or ascii-symbols-not-colon ascii-colon))

(define-peg-pattern ascii body
  (or uppercase lowercase numbers ascii-symbols))

(define-peg-pattern asciis body
  (+ ascii))

(define-peg-pattern ascii-no-colon body
  (or uppercase lowercase numbers ascii-symbols-not-colon))

(define-peg-pattern tag all
  alphanum)

(define-peg-pattern not-tag all
  ascii-symbols-not-colon)

(define-peg-pattern tagset all
  (and ":" tag (* (and ":" tag)) ":"))

(define-peg-pattern state all
  (or "TODO"
      "NEXT"
      "WAIT"
      "DEFER"
      "DONE"
      "NVM"
      "PROJECT"))

(define-peg-pattern eof all
  (not-followed-by peg-any))

;; TODO parse clock entries!
(define-peg-pattern ascii-not-end body
  (and (not-followed-by ":END:") asciis))

(define-peg-pattern logbook-field all
  ascii-not-end)

(define-peg-pattern logbook-drawer all
  (and blanks ":LOGBOOK:" nl
       (* (and blanks logbook-field nl))
       blanks ":END:" nl))

(define-peg-pattern ascii-no-colon-not-end body
  (and (not-followed-by "END") (+ ascii-no-colon)))
(define-peg-pattern property-field all
  (and ":" (+ ascii-no-colon-not-end) ":" blanks (? asciis)))

(define-peg-pattern property-drawer all
  (and blanks ":PROPERTIES:" nl
       (* (and blanks property-field nl))
       blanks ":END:" nl))

(define-peg-pattern drawers all
  (+ (or property-drawer logbook-drawer)))

(define-peg-pattern priority all
  (and "[#" uppercase "]"))

(define-peg-pattern title all
  (and asciis (not-followed-by tagset)))

(define-peg-pattern heading all
  (and (? (and state space))
       (? (and priority space))
       (? title)
       (? tagset)
       nl))

(define-peg-pattern node-body all
  (* (or nl (not-followed-by star) (and (not-followed-by star) (+ peg-any)))))

(define-peg-pattern node all
  (and stars space heading node-body))

(define-peg-pattern header all
  (and "#" "+" (+ alphanum) ascii-colon blanks asciis nl))

(define-peg-pattern comment all
  (and "#" (not-followed-by "+") asciis nl))

(define-peg-pattern orgdoc all
  (* (or comment header node nl)))
;; add (not-followed-by peg-any)

(define (orgparse-tree str)
  (match-pattern orgdoc str))
