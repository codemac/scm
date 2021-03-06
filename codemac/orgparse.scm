(define-module (codemac orgparse)
  #:use-module (rx irregex)
  #:use-module (ice-9 peg)
  #:export (orgparse-tree))

(define-peg-pattern nl none
  "\n")

(define-peg-pattern whitespace none
  (or "\n" "\t" " "))

(define-peg-pattern space none
  " ")

(define-peg-pattern blanks all
  (* space))

(define-peg-pattern stars all
  (+ "*"))

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

(define-peg-pattern ascii-symbols-not-colon body
  (or "#"  "-"  "_"  "}"  "$"  "."  "`"  "~"  "%"  "/"  " "
      "&"  "'"  ";"  "("  "<"  ")"  "="  "["  "*"  ">"  "\\"
      "!"  "+"  "?"  "]"  "{"  "\"" ","  "@"  "^"  "|"))

(define-peg-pattern ascii-symbols body
  (or ascii-symbols-not-colon ascii-colon))

(define-peg-pattern ascii body
  (or uppercase lowercase numbers ascii-symbols))

(define-peg-pattern asciis all
  (+ ascii))

(define-peg-pattern tag all
  alphanum)

(define-peg-pattern not-tag body
  ascii-symbols-not-colon)

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

(define-peg-pattern eof all
  (not-followed-by peg-any))

(define-peg-pattern node-body all
  (and (* (or asciis nl)) (followed-by (or (and nl stars) (and nl eof)))))

;; TODO parse clock entries!
(define-peg-pattern logbook-field all
  (* ascii))

(define-peg-pattern logbook-drawer all
  (and blanks ":LOGBOOK:" nl
       (* (and blanks logbook-field))
       blanks ":END:" nl))

(define-peg-pattern property-field all
  (and ":" uppercase ":" blanks asciis nl))

(define-peg-pattern property-drawer all
  (and blanks ":PROPERTIES:" nl
       (* (and blanks property-field))
       blanks ":END:" nl))

(define-peg-pattern drawers all
  (+ (or property-drawer
	 logbook-drawer)))

(define-peg-pattern priority all
  (and "[#" uppercase "]"))

(define-peg-pattern heading all
  (and (? (and space state))
       (? (and space priority))
       (? (or (and space asciis (not-followed-by (and space tagset)))
	      (and space asciis space tagset)))
       (? (and nl (+ drawers)))))

(define-peg-pattern node all
  (and stars heading
       nl node-body))

(define-peg-pattern header all
  (and "#+" alphanum ":" blanks asciis nl))

(define-peg-pattern comment all
  (and "#" asciis nl))

(define-peg-pattern orgdoc all
  (and (* (or whitespace header comment)) (* node)))

(define (orgparse-tree str)
  (match-pattern orgdoc str))

