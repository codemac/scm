(define-module (codemac orgparse)
  #:use-module (codemac vendor irregex))

;; things:
;;
;; regex => lexer
;; chars -> lexer => tokens
;;
;; CFG => parser
;; tokens -> parser => AST

(define stars
  '(: bol (+  "*")))

(define title
  `(:  ))

