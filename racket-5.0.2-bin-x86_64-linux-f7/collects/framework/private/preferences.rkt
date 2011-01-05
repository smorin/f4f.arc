#lang scheme/unit

#|

There are three attributes for each preference:

  - default set, or not
  - marshalling function set, or not
  - initialization still okay, or not

the state transitions / contracts are:

  get(true, _, _) -> (true, _, false)
  get(false, _, _) -> error default not yet set

  set is just like get.

  set-default(false, _, true) -> set-default(true, _, true)
  set-default(true, _, _) -> error default already set
  set-default(_, _, false) -> initialization not okay anymore  /* cannot happen, I think */

  set-un/marshall(true, false, true) -> (true, true, true)
  .. otherwise error

  for all syms: 
   prefs-snapshot(_, _, _) -> (_, _, false) 

|#


  (require string-constants
	   mzlib/class
           scheme/file
           "sig.ss"
           "../gui-utils.ss"
           "../preferences.ss"
	   mred/mred-sig
	   mzlib/list)
  
  (import mred^
          [prefix exit: framework:exit^]
          [prefix panel: framework:panel^]
          [prefix frame: framework:frame^])
  (export framework:preferences^)
  
  (define past-failure-ps '())
  (define past-failure-vs '())
  (define number-of-consecutive-failures 0)

  (define (put-preferences/gui new-ps new-vs)
    
    ;; NOTE: old ones must come first in the list, 
    ;; or else multiple sets to the same preference
    ;; will save old values, instead of new ones.
    (define ps (begin0 (append past-failure-ps new-ps)
                       (set! past-failure-ps '())))
    (define vs (begin0 (append past-failure-vs new-vs)
                       (set! past-failure-vs '())))
    
    (define failed #f)
    (define (record-actual-failure)
      (set! number-of-consecutive-failures (+ number-of-consecutive-failures 1))
      (set! past-failure-ps ps)
      (set! past-failure-vs vs)
      (set! failed #t))
    (define (fail-func path)
      (cond
        [(= number-of-consecutive-failures 3)
         (set! number-of-consecutive-failures 0)
         (let ([mb-ans
                (message-box/custom
                 (string-constant error-saving-preferences-title)
                 (format (string-constant prefs-file-locked)
                         (path->string path))
                 (string-constant steal-the-lock-and-retry)
                 (string-constant cancel)
                 #f
                 #f ;;parent
                 '(default=2 caution))])
           (case mb-ans
             [(2 #f) (record-actual-failure)]
             [(1) 
              (let ([delete-failed #f])
                (with-handlers ((exn:fail:filesystem? (λ (x) (set! delete-failed x))))
                  (delete-file path))
                (cond
                  [delete-failed
                   (record-actual-failure)
                   (message-box 
                    (string-constant error-saving-preferences-title)
                    (exn-message delete-failed))]
                  [else
                   (put-preferences ps vs second-fail-func)]))]))]
        [else 
         (record-actual-failure)]))
    (define (second-fail-func path)
      (record-actual-failure)
      (message-box
       (string-constant error-saving-preferences-title)
       (format (string-constant prefs-file-still-locked)
               (path->string path))
       #f
       '(stop ok)))
    (with-handlers ((exn? 
                     (λ (x)
                       (message-box
                        (string-constant drscheme)
                        (format (string-constant error-saving-preferences)
                                (exn-message x))))))
      (begin0
        (put-preferences ps vs fail-func)
        (unless failed
          (set! number-of-consecutive-failures 0)))))
  
  ;; ppanel-tree = 
  ;;  (union (make-ppanel-leaf string (union #f panel) (panel -> panel))
  ;;         (make-ppanel-interior string (union #f panel) (listof panel-tree)))
  (define-struct ppanel (name panel))
  (define-struct (ppanel-leaf ppanel) (maker))
  (define-struct (ppanel-interior ppanel) (children) #:mutable)
  
  ;; ppanels : (listof ppanel-tree)
  (define ppanels null)
  
  (define preferences-dialog #f)
  
  (define (add-panel title make-panel)
    (when preferences-dialog
      (error 'add-panel "preferences dialog already open, cannot add new panels"))
    (let ([titles (if (string? title)
                      (list title)
                      title)])
      (add-to-existing-children
       titles 
       make-panel
       (λ (new-ppanels) (set! ppanels new-ppanels)))))
  
  ;; add-to-existing-children : (listof string) (panel -> panel) (ppanel -> void)
  ;; adds the child specified by the path in-titles to the tree.
  (define (add-to-existing-children in-titles make-panel banger)
    (let loop ([children ppanels]
               [title (car in-titles)]
               [titles (cdr in-titles)]
               [banger banger])
      (cond
        [(null? children)
         (banger (list (build-new-subtree (cons title titles) make-panel)))]
        [else
         (let ([child (car children)])
           (if (string=? (ppanel-name child) title)
               (cond
                 [(null? titles) 
                  (error 'add-child "child already exists with this path: ~e" in-titles)]
                 [(ppanel-leaf? child)
                  (error 'add-child "new child's path conflicts with existing path: ~e" in-titles)]
                 [else
                  (loop
                   (ppanel-interior-children child)
                   (car titles)
                   (cdr titles)
                   (λ (children)
                     (set-ppanel-interior-children! 
                      child
                      children)))])
               (loop 
                (cdr children)
                title
                titles
                (λ (children)
                   (banger (cons child children))))))])))

  ;; build-new-subtree : (cons string (listof string)) (panel -> panel) -> ppanel
  (define (build-new-subtree titles make-panel)
    (let loop ([title (car titles)]
               [titles (cdr titles)])
      (cond
        [(null? titles) (make-ppanel-leaf title #f make-panel)]
        [else
         (make-ppanel-interior 
          title
          #f
          (list (loop (car titles) (cdr titles))))])))
  
  
  (define (hide-dialog)
    (when preferences-dialog
      (send preferences-dialog close)))
  
  (define (show-dialog)
    (if preferences-dialog
        (send preferences-dialog show #t)
        (set! preferences-dialog
              (make-preferences-dialog))))
  
  (define (add-can-close-dialog-callback cb)
    (set! can-close-dialog-callbacks
          (cons cb can-close-dialog-callbacks)))
  
  (define (add-on-close-dialog-callback cb)
    (set! on-close-dialog-callbacks
          (cons cb on-close-dialog-callbacks)))
  
  (define on-close-dialog-callbacks null)
  
  (define can-close-dialog-callbacks null)
  
  (define (make-preferences-dialog)
    (letrec ([stashed-prefs (preferences:get-prefs-snapshot)]
             [cancelled? #t]
             [frame-stashed-prefs%
              (class frame:basic%
                (inherit close)
                (define/override (on-subwindow-char receiver event)
                  (cond
                    [(eq? 'escape (send event get-key-code))
                     (close)]
                    [else 
                     (super on-subwindow-char receiver event)]))
                (define/augment (on-close)
                  (when cancelled?
                    (preferences:restore-prefs-snapshot stashed-prefs)))
                (define/override (show on?)
                  (when on?
                    ;; reset the flag and save new prefs when the window becomes visible
                    (set! cancelled? #t)
                    (set! stashed-prefs (preferences:get-prefs-snapshot)))
                  (super show on?))
                (super-new))]
             [frame 
              (new frame-stashed-prefs%
                   [label (string-constant preferences)]
                   [height 200])]
             [build-ppanel-tree
              (λ (ppanel tab-panel single-panel)
                (send tab-panel append (ppanel-name ppanel))
                (cond
                  [(ppanel-leaf? ppanel) 
                   ((ppanel-leaf-maker ppanel) single-panel)]
                  [(ppanel-interior? ppanel)
                   (let-values ([(tab-panel single-panel) (make-tab/single-panel single-panel #t)])
                     (for-each
                      (λ (ppanel) (build-ppanel-tree ppanel tab-panel single-panel))
                      (ppanel-interior-children ppanel)))]))]
             [make-tab/single-panel 
              (λ (parent inset?)
                (letrec ([spacer (and inset?
                                      (instantiate vertical-panel% ()
                                        (parent parent)
                                        (border 10)))]
                         [tab-panel (instantiate tab-panel% ()
                                      (choices null)
                                      (parent (if inset? spacer parent))
                                      (callback (λ (_1 _2) 
                                                  (tab-panel-callback
                                                   single-panel
                                                   tab-panel))))]
                         [single-panel (instantiate panel:single% ()
                                         (parent tab-panel))])
                  (values tab-panel single-panel)))]
             [tab-panel-callback
              (λ (single-panel tab-panel)
                (send single-panel active-child
                      (list-ref (send single-panel get-children)
                                (send tab-panel get-selection))))]
             [panel (make-object vertical-panel% (send frame get-area-container))]
             [_ (let-values ([(tab-panel single-panel) (make-tab/single-panel panel #f)])
                  (for-each
                   (λ (ppanel)
                     (build-ppanel-tree ppanel tab-panel single-panel))
                   ppanels)
                  (let ([single-panel-children (send single-panel get-children)])
                    (unless (null? single-panel-children)
                      (send single-panel active-child (car single-panel-children))
                      (send tab-panel set-selection 0)))
                  (send tab-panel focus))]
             [bottom-panel (make-object horizontal-panel% panel)]
             [ok-callback (λ args
                            (when (andmap (λ (f) (f))
                                          can-close-dialog-callbacks)
                              (for-each
                               (λ (f) (f))
                               on-close-dialog-callbacks)
                              (set! cancelled? #f)
                              (send frame close)))]
             [cancel-callback (λ () (send frame close))])
      (new button%
           [label (string-constant revert-to-defaults)]
           [callback
            (λ (a b)
              (preferences:restore-defaults))]
           [parent bottom-panel])
      (new horizontal-panel% [parent bottom-panel]) ;; spacer
      (gui-utils:ok/cancel-buttons
       bottom-panel
       ok-callback
       (λ (a b) (cancel-callback)))
      (make-object grow-box-spacer-pane% bottom-panel)
      (send* bottom-panel
        (stretchable-height #f)
        (set-alignment 'right 'center))
      (send frame show #t)
      frame))
  
  (define (add-to-scheme-checkbox-panel f)
    (set! scheme-panel-procs 
          (let ([old scheme-panel-procs])
            (λ (parent) (old parent) (f parent)))))
  
  (define (add-to-editor-checkbox-panel f)
    (set! editor-panel-procs 
          (let ([old editor-panel-procs])
            (λ (parent) (old parent) (f parent)))))
  
  (define (add-to-general-checkbox-panel f)
    (set! general-panel-procs 
          (let ([old general-panel-procs])
            (λ (parent) (old parent) (f parent)))))
  
  (define (add-to-warnings-checkbox-panel f)
    (set! warnings-panel-procs 
          (let ([old warnings-panel-procs])
            (λ (parent) (old parent) (f parent)))))
  
  (define scheme-panel-procs void)
  (define editor-panel-procs void)
  (define general-panel-procs void)
  (define warnings-panel-procs void)
  
  (define (add-checkbox-panel label proc)
    (add-panel
     label
     (λ (parent)
       (let* ([main (make-object vertical-panel% parent)])
         (send main set-alignment 'left 'center)
         (proc main)
         main))))
  
  ;; make-check : panel symbol string (boolean -> any) (any -> boolean)
  ;; adds a check box preference to `main'.
  (define (make-check main pref title bool->pref pref->bool)
    (let* ([callback
            (λ (check-box _)
              (preferences:set pref (bool->pref (send check-box get-value))))]
           [pref-value (preferences:get pref)]
           [initial-value (pref->bool pref-value)]
           [c (make-object check-box% title main callback)])
      (send c set-value initial-value)
      (preferences:add-callback
       pref
       (λ (p v)
         (send c set-value (pref->bool v))))))
  
  (define (make-recent-items-slider parent)
    (let ([slider (instantiate slider% ()
                    (parent parent)
                    (label (string-constant number-of-open-recent-items))
                    (min-value 1)
                    (max-value 100)
                    (init-value (preferences:get 'framework:recent-max-count))
                    (callback (λ (slider y)
                                (preferences:set 'framework:recent-max-count
                                                 (send slider get-value)))))])
      (preferences:add-callback
       'framework:recent-max-count
       (λ (p v)
         (send slider set-value v)))))
  
  (define (add-scheme-checkbox-panel)
    (letrec ([add-scheme-checkbox-panel
              (λ ()
                (set! add-scheme-checkbox-panel void)
                (add-checkbox-panel
                 (list 
                  (string-constant editor-prefs-panel-label) 
                  (string-constant scheme-prefs-panel-label))
                 (λ (scheme-panel)
                   (make-check scheme-panel
                               'framework:highlight-parens
                               (string-constant highlight-parens)
                               values values)
                   (make-check scheme-panel
                               'framework:fixup-parens
                               (string-constant fixup-close-parens)
                               values values)
                   (make-check scheme-panel
                               'framework:fixup-open-parens
                               (string-constant fixup-open-brackets)
                               values values)
                   (make-check scheme-panel
                               'framework:paren-match
                               (string-constant flash-paren-match)
                               values values)
                   (scheme-panel-procs scheme-panel))))])
      (add-scheme-checkbox-panel)))
  
  (define (add-editor-checkbox-panel)
    (letrec ([add-editor-checkbox-panel
              (λ ()
                (set! add-editor-checkbox-panel void)
                (add-checkbox-panel 
                 (list (string-constant editor-prefs-panel-label) 
                       (string-constant general-prefs-panel-label))
                 (λ (editor-panel)
                   (make-check editor-panel  'framework:delete-forward? (string-constant map-delete-to-backspace)
                               not not)
                   (make-check editor-panel 
                               'framework:auto-set-wrap?
                               (string-constant wrap-words-in-editor-buffers)
                               values values)
                   (make-check editor-panel 
                               'framework:open-here?
                               (string-constant reuse-existing-frames)
                               values values)
                   
                   (make-check editor-panel 
                               'framework:menu-bindings
                               (string-constant enable-keybindings-in-menus)
                               values values)
                   (when (memq (system-type) '(macosx))
                     (make-check editor-panel 
                                 'framework:special-meta-key
                                 (string-constant command-as-meta)
                                 values values))
                   
                   (make-check editor-panel 
                               'framework:coloring-active
                               (string-constant online-coloring-active)
                               values values)
                   
                   (make-check editor-panel
                               'framework:anchored-search
                               (string-constant find-anchor-based)
                               values values)
                   (make-check editor-panel
                               'framework:do-paste-normalization
                               (string-constant normalize-string-preference)
                               values values)
                   (make-check editor-panel
                               'framework:overwrite-mode-keybindings
                               (string-constant enable-overwrite-mode-keybindings)
                               values values)
                   (editor-panel-procs editor-panel))))])
      (add-editor-checkbox-panel)))
  
  (define (add-general-checkbox-panel)
    (letrec ([add-general-checkbox-panel
              (λ ()
                (set! add-general-checkbox-panel void)
                (add-checkbox-panel 
                 (list (string-constant general-prefs-panel-label))
                 (λ (editor-panel)
                   (make-recent-items-slider editor-panel)
                   (make-check editor-panel
                               'framework:autosaving-on? 
                               (string-constant auto-save-files)
                               values values)
                   (make-check editor-panel  'framework:backup-files? (string-constant backup-files) values values)
                   (make-check editor-panel 'framework:show-status-line (string-constant show-status-line) values values)
                   (make-check editor-panel 'framework:col-offsets (string-constant count-columns-from-one) values values)
                   (make-check editor-panel 
                               'framework:display-line-numbers
                               (string-constant display-line-numbers)
                               values values)
                   (unless (eq? (system-type) 'unix) 
                     (make-check editor-panel 
                                 'framework:print-output-mode 
                                 (string-constant automatically-to-ps)
                                 (λ (b) 
                                   (if b 'postscript 'standard))
                                 (λ (n) (eq? 'postscript n))))
                   (general-panel-procs editor-panel))))])
      (add-general-checkbox-panel)))
  
  (define (add-warnings-checkbox-panel)
    (letrec ([add-warnings-checkbox-panel
              (λ ()
                (set! add-warnings-checkbox-panel void)
                (add-checkbox-panel
                 (string-constant warnings-prefs-panel-label)
                 (λ (warnings-panel)
                   (make-check warnings-panel 
                               'framework:verify-change-format 
                               (string-constant ask-before-changing-format)
                               values values)
                   (make-check warnings-panel 
                               'framework:verify-exit
                               (string-constant verify-exit)
                               values values)
                   (make-check warnings-panel
                               'framework:ask-about-paste-normalization
                               (string-constant ask-about-normalizing-strings)
                               values values)
                   (warnings-panel-procs warnings-panel))))])
      (add-warnings-checkbox-panel)))
  
  (define (local-add-font-panel)
    (let* ([font-families-name/const
            (list (list "Default" 'default)
                  (list "Decorative" 'decorative)
                  (list "Modern" 'modern)
                  (list "Roman" 'roman)
                  (list "Script" 'script)
                  (list "Swiss" 'swiss))]
           
           [font-families (map car font-families-name/const)]
           
           [font-size-entry "defaultFontSize"]
           [font-default-string "Default Value"]
           [font-default-size (case (system-type)
                                [(windows) 10]
                                [(macosx) 13]
                                [else 12])]
           [font-section "mred"]
           [build-font-entry (λ (x) (string-append "Screen" x "__"))]
           [font-file (find-graphical-system-path 'setup-file)]
           [build-font-preference-symbol
            (λ (family)
              (string->symbol (string-append "framework:" family)))]
           
           [set-default
            (λ (build-font-entry default pred)
              (λ (family)
                (let ([name (build-font-preference-symbol family)]
                      [font-entry (build-font-entry family)])
                  (preferences:set-default
                   name
                   default
                   (cond
                     [(string? default) string?]
                     [(number? default) number?]
                     [else (error 'internal-error.set-default "unrecognized default: ~a\n" default)]))
                  (preferences:add-callback 
                   name 
                   (λ (p new-value)
                     (write-resource 
                      font-section
                      font-entry
                      (if (and (string? new-value)
                               (string=? font-default-string new-value))
                          ""
                          new-value)
                      font-file))))))])
      
      (for-each (set-default build-font-entry font-default-string string?)
                font-families)
      ((set-default (λ (x) x)
                    font-default-size
                    number?)
       font-size-entry)
      (add-panel
       (string-constant default-fonts)
       (λ (parent)
         (letrec ([font-size-pref-sym (build-font-preference-symbol font-size-entry)]
                  [ex-string (string-constant font-example-string)]
                  [main (make-object vertical-panel% parent)]
                  [fonts (cons font-default-string (get-face-list))]
                  [make-family-panel
                   (λ (name)
                     (let* ([pref-sym (build-font-preference-symbol name)]
                            [family-const-pair (assoc name font-families-name/const)]
                            
                            [edit (make-object text%)]
                            [_ (send edit insert ex-string)]
                            [set-edit-font
                             (λ (size)
                               (let ([delta (make-object style-delta% 'change-size size)]
                                     [face (preferences:get pref-sym)])
                                 (if (and (string=? face font-default-string)
                                          family-const-pair)
                                     (send delta set-family (cadr family-const-pair))
                                     (send delta set-delta-face (preferences:get pref-sym)))
                                 
                                 (send edit change-style delta 0 (send edit last-position))))]
                            
                            [horiz (make-object horizontal-panel% main '(border))]
                            [label (make-object message% name horiz)]
                            
                            [message (make-object message%
                                       (let ([b (box "")])
                                         (if (and (get-resource 
                                                   font-section 
                                                   (build-font-entry name)
                                                   b)
                                                  (not (string=? (unbox b) 
                                                                 "")))
                                             (unbox b)
                                             font-default-string)) 
                                       horiz)]
                            [button 
                             (make-object button%
                               (string-constant change-font-button-label)
                               horiz
                               (λ (button evt)
                                 (let ([new-value
                                        (get-choices-from-user
                                         (string-constant fonts)
                                         (format (string-constant choose-a-new-font)
                                                 name)
                                         fonts)])
                                   (when new-value
                                     (preferences:set pref-sym (list-ref fonts (car new-value))) 
                                     (set-edit-font (preferences:get font-size-pref-sym))))))]
                            [canvas (make-object editor-canvas% horiz
                                      edit
                                      (list 'hide-hscroll
                                            'hide-vscroll))])
                       (set-edit-font (preferences:get font-size-pref-sym))
                       (preferences:add-callback
                        pref-sym
                        (λ (p new-value)
                          (send horiz change-children
                                (λ (l)
                                  (let ([new-message (make-object message%
                                                       new-value
                                                       horiz)])
                                    (set! message new-message)
                                    (update-message-sizes font-message-get-widths 
                                                          font-message-user-min-sizes)
                                    (list label 
                                          new-message
                                          button
                                          canvas))))))
                       (send canvas set-line-count 1)
                       (vector set-edit-font
                               (λ () (send message get-width))
                               (λ (width) (send message min-width width))
                               (λ () (send label get-width))
                               (λ (width) (send label min-width width)))))]
                  [set-edit-fonts/messages (map make-family-panel font-families)]
                  [collect (λ (n) (map (λ (x) (vector-ref x n))
                                       set-edit-fonts/messages))]
                  [set-edit-fonts (collect 0)]
                  [font-message-get-widths (collect 1)]
                  [font-message-user-min-sizes (collect 2)]
                  [category-message-get-widths (collect 3)]
                  [category-message-user-min-sizes (collect 4)]
                  [update-message-sizes
                   (λ (gets sets)
                     (let ([width (foldl (λ (x l) (max l (x))) 0 gets)])
                       (for-each (λ (set) (set width)) sets)))]
                  [size-panel (make-object horizontal-panel% main '(border))]
                  [initial-font-size
                   (let ([b (box 0)])
                     (if (get-resource font-section 
                                       font-size-entry
                                       b)
                         (unbox b)
                         font-default-size))]
                  [size-slider
                   (make-object slider%
                     (string-constant font-size-slider-label)
                     1 127
                     size-panel
                     (λ (slider evt)
                       (preferences:set font-size-pref-sym (send slider get-value)))
                     initial-font-size)])
           (update-message-sizes font-message-get-widths font-message-user-min-sizes)
           (update-message-sizes category-message-get-widths category-message-user-min-sizes)
           (preferences:add-callback
            font-size-pref-sym
            (λ (p value)
              (for-each (λ (f) (f value)) set-edit-fonts)
              (unless (= value (send size-slider get-value))
                (send size-slider set-value value))
              #t))
           (for-each (λ (f) (f initial-font-size)) set-edit-fonts)
           (make-object message% (string-constant restart-to-see-font-changes) main)
           main))))
    (set! local-add-font-panel void))
  
  (define (add-font-panel) (local-add-font-panel))