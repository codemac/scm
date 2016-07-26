(define-module (codemac orgparse)
  #:use-module (codemac vendor irregex)
  #:use-module (system base lalr))

(define (make-orgparser)
  (lalr-parser
   (stars)
   ))

;; things:
;;
;; regex => lexer
;; chars -> lexer => tokens
;;
;; CFG => parser
;; tokens -> parser => AST

(define stars
  '(: bol (+  "*")))

(define body
  '(: bol (+ (- stars))))
(define title
  `(:  ))



;; org file grammar
;;
;; org_doc = <headers> <org_nodes>
;; headers = <header> | ...
;; header = #+<header_name>: <string>$
;; header_name = startup | last_mobile_change | ...
;; org_node = <org_node_title>\n<org_node_content>
;; org_node_title = <stars> <state> <priority> <title> <tags>
;; stars = <star>..
;; star = *
;; state = TODO | STARTED | NEXT | DONE | NVM
;; priority = [#<pri_letter>]
;; pri_letter = A | B | C
;; title = <words>
;; tags = :<tagname>: | :<tagname>:<tagname>: | ...
;; tagname = PROJECT | COMPUTER | INTERNET | WORK | HOME | ERRAND | PHONE
;; org_node_content = <drawers> <notes>
;; drawers = <property_drawer> | <logbook_drawer> | ...
;; property_drawer = :PROPERTIES:\n<drawer_vals>\n:END:
;; property_drawer_vals = <id_val> | <ordered_val> | <generic_val> | ...
;; property_drawer_id_val = :ID: <symbols>\n
;; property_drawer_ordered_val = :ORDERED:<spaces><truthy>\n
;; property_drawer_truthy = t | f

(define org_doc `(: ,headers ,org_nodes))
(define headers `(or ,header_startup ))

(define (org_header name)
  `(: "#+" (w/nocase ,name) ":" whitespace alpha eol))

(define (blank_or sre)
  `(or ,sre ""))
(define header_startup `(: ,(org_header "startup")))
(define org_node `(: ,org_node_title eol bol ,org_node_contents))
(define org_node_title `(: bol ,stars whitespace () (blank_or)))
