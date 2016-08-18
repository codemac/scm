;;; The inhabitants of the planet Splurth are building their own
;;; periodic table of the elements. Just like Earth's periodic table
;;; has a chemical symbol for each element (H for Hydrogen, Li for
;;; Lithium, etc.), so does Splurth's. However, their chemical symbols
;;; must follow certain rules:
;;;
;;; - All chemical symbols must be exactly two letters, so B is not a
;;;   valid symbol for Boron.
;;; 
;;; - Both letters in the symbol must appear in the element name, but
;;;   the first letter of the element name does not necessarily need
;;;   to appear in the symbol. So Hg is not valid for Mercury, but Cy
;;;   is.
;;; 
;;; - The two letters must appear in order in the element name. So Vr
;;;   is valid for Silver, but Rv is not. To be clear, both Ma and Am
;;;   are valid for Magnesium, because there is both an a that appears
;;;   after an m, and an m that appears after an a.
;;; 
;;; - If the two letters in the symbol are the same, it must appear
;;;   twice in the element name. So Nn is valid for Xenon, but Xx and
;;;   Oo are not.
;;;
;;; As a member of the Splurth Council of Atoms and Atom-Related
;;; Paraphernalia, you must determine whether a proposed chemical
;;; symbol fits these rules.
;;;
;;; Details
;;; 
;;; Write a function that, given two strings, one an element name and
;;; one a proposed symbol for that element, determines whether the
;;; symbol follows the rules. If you like, you may parse the program's
;;; input and output the result, but this is not necessary.
;;; 
;;; The symbol will have exactly two letters. Both element name and
;;; symbol will contain only the letters a-z. Both the element name
;;; and the symbol will have their first letter capitalized, with the
;;; rest lowercase. (If you find that too challenging, it's okay to
;;; instead assume that both will be completely lowercase.)
;;; 
;;; Examples

;;; Spenglerium, Ee -> true
;;; Zeddemorium, Zr -> true
;;; Venkmine, Kn -> true
;;; Stantzon, Zt -> false
;;; Melintzum, Nn -> false
;;; Tullium, Ty -> false
;;; 
;;; Optional bonus challenges
;;; 
;;; - Given an element name, find the valid symbol for that name
;;; that's first in alphabetical order. E.g. Gozerium -> Ei, Slimyrine
;;; -> Ie.
;;;
;;; - Given an element name, find the number of distinct valid symbols
;;; for that name. E.g. Zuulon -> 11.
;;;
;;; - The planet Blurth has similar symbol rules to Splurth, but
;;; symbols can be any length, from 1 character to the entire length
;;; of the element name. Valid Blurthian symbols for Zuulon include N,
;;; Uuo, and Zuuln. Complete challenge #2 for the rules of
;;; Blurth. E.g. Zuulon -> 47.
;;;
;;; 

(define (string-ordered-chars? str chrs)
  (define (string-ordered-chars-tco s c)
    (cond
     ((null? c) #t)
     ((null? s) #f)
     ((equal? (car s) (car c))
      (string-ordered-chars-tco (cdr s) (cdr c)))
     (else
      (string-ordered-chars-tco (cdr s) c))))
  (string-ordered-chars-tco (string->list str) (string->list chrs)))

(define (splurthian-element? name elt)
  (and
   (eq? (string-length elt) 2)
   (string-ordered-chars? (string-downcase name)
			  (string-downcase elt))))

(define examples '(("Spenglerium" . "Ee")
		   ("Zeddemorium" . "Zr")
		   ("Venkmine" . "Kn")
		   ("Stantzon" . "Zt")
		   ("Melintzum" . "Nn")
		   ("Tullium" . "Ty")))

(map (lambda (p) (splurthian-element? (car p) (cdr p)))
     examples) ; => '(#t #t #t #f #f #f)

(define (unique-letters-hash str)
  (let ((h (make-hash-table (string-length str))))
    (for-each (lambda (x) (hashq-set! h x 0)) (string->list (string-downcase str)))
    (hash-count (const #t) h)))

(define (unique-letters str)
  (define (tco strl acc)
    (cond
     ((null? strl)
      (length acc))
     ((memq (car strl) acc)
      (tco (cdr strl) acc))
     (else
      (tco (cdr strl) (cons (car strl) acc)))))
  (tco str '()))

(define (splurthian-name-count str)
  (define (tco s acc)
    (if (or (null? s) (null? (cdr s)))
	acc
	(tco (cdr s) (+ acc (unique-letters (cdr s))))))
  (tco (string->list str) 0))
