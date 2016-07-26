(use-modules (ice-9 rdelim))

;; You'll be given a number N, representing the number of lines of
;; BASIC code. Following that will be a line containing the text to
;; use for indentation, which will be ···· for the purposes of
;; visibility. Finally, there will be N lines of pseudocode mixing
;; indentation types (space and tab, represented by · and » for
;; visibility) that need to be reindented.
;;
;; Blocks are denoted by IF and ENDIF, as well as FOR and NEXT.

(define whitespace '(· »))
