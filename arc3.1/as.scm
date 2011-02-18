; mzscheme -m -f as.scm
; (tl)
; (asv)
; http://localhost:8080

(require mzscheme) ; promise we won't redefine mzscheme bindings

(require "ac.scm") 
(require "brackets.scm")
(use-bracket-readtable)

(aload "arc.arc")
(aload "libs.arc") 

;(tl)
; Added from Anarki

;need to add support for commandline args
;http://docs.racket-lang.org/reference/runtime.html?q=args#(def._((quote._~23~25kernel)._current-command-line-arguments))
;http://docs.racket-lang.org/reference/Command-Line_Parsing.html?q=args#(form._((lib._racket/cmdline..rkt)._command-line))
;http://docs.racket-lang.org/reference/Command-Line_Parsing.html?q=args
;http://docs.racket-lang.org/slideshow/Creating_Slide_Presentations.html?q=args#(part._.Command-line_.Options)

(let ((args (vector->list (current-command-line-arguments))))
  (if (null? args)
    (tl)
    ; command-line arguments are script filenames to execute
    (for-each (lambda (f) (aload f)) args)))