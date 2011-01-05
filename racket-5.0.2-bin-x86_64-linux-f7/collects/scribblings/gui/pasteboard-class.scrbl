#lang scribble/doc
@(require "common.ss")

@defclass/title[pasteboard% object% (editor<%>)]{

A @scheme[pasteboard%] object is an editor for displaying snips with
 arbitrary @techlink{location}s.

@defconstructor[()]{

The editor will not be displayed until it is attached to an
 @scheme[editor-canvas%] object or some other @techlink{display}.

A new @scheme[keymap%] object is created for the new editor.  See also
 @method[editor<%> get-keymap] and @method[editor<%> set-keymap].

A new @scheme[style-list%] object is created for the new editor.  See
 also @method[editor<%> get-style-list] and @method[editor<%>
 set-style-list].

}


@defmethod*[([(add-selected [snip (is-a?/c snip%)])
              void?]
             [(add-selected [x real?]
                            [y real?]
                            [w (and/c real? (not/c negative?))]
                            [h (and/c real? (not/c negative?))])
              void?])]{

Selects snips without deselecting other snips. When coordinates are
 given, this method selects all snips that intersect with the given
 rectangle (in editor coordinates).

@|OnSelectNote|

}


@defmethod[#:mode pubment 
           (after-delete [snip (is-a?/c snip%)])
           void?]{
@methspec{

Called after a snip is deleted from the editor (and after the
 @techlink{display} is refreshed; use @method[pasteboard% on-delete]
 and @method[editor<%> begin-edit-sequence] to avoid extra refreshes
 when @method[pasteboard% after-delete] modifies the editor).

See also @method[pasteboard% can-delete?] and @method[editor<%>
 on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{
Does nothing.
}
}


@defmethod[#:mode pubment 
           (after-insert [snip (is-a?/c snip%)]
                         [before (or/c (is-a?/c snip%) false/c)]
                         [x real?]
                         [y real?])
           void?]{

@methspec{

Called after a snip is inserted into the editor (and after the
 @techlink{display} is refreshed; use @method[pasteboard% on-insert]
 and @method[editor<%> begin-edit-sequence] to avoid extra refreshes
 when @method[pasteboard% after-insert] modifies the editor).

See also @method[pasteboard% can-insert?] and @method[editor<%>
 on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{
Does nothing.
}
}


@defmethod[#:mode pubment 
           (after-interactive-move [event (is-a?/c mouse-event%)])
           void?]{
@methspec{

Called after the user stops interactively dragging snips (the ones
 that are selected; see @method[pasteboard%
 find-next-selected-snip]). The mouse event that terminated the move
 (usually a button-up event) is provided.

See also @method[pasteboard% can-interactive-move?] and
 @method[pasteboard% on-interactive-move].

}
@methimpl{

Does nothing.

}
}


@defmethod[#:mode pubment 
           (after-interactive-resize [snip (is-a?/c snip%)])
           void?]{
@methspec{

Called after the user stops interactively resizing a snip (the one
 that is currently selected; see @method[pasteboard%
 find-next-selected-snip]). The @scheme[snip] argument is the snip
 that was resized.

See also @method[pasteboard% can-interactive-resize?] and
 @method[pasteboard% on-interactive-resize].

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (after-move-to [snip (is-a?/c snip%)]
                          [x real?]
                          [y real?]
                          [dragging? any/c])
           void?]{
@methspec{

Called after a given snip is moved within the editor (and after the
 @techlink{display} is refreshed; use @method[pasteboard% on-move-to]
 and @method[editor<%> begin-edit-sequence] to avoid extra refreshes
 when @method[pasteboard% after-move-to] modifies the editor).

If @scheme[dragging?] is not @scheme[#f], then this move was a temporary
 move for dragging.

See also
 @method[pasteboard% can-move-to?] and
 @method[editor<%> on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (after-reorder [snip (is-a?/c snip%)]
                          [to-snip (is-a?/c snip%)]
                          [before? any/c])
           boolean?]{
@methspec{

Called before a snip is moved in the pasteboard's front-to-back snip
 order (and after the @techlink{display} is refreshed; use
 @method[pasteboard% on-reorder] and @method[editor<%>
 begin-edit-sequence] to avoid extra refreshes when
 @method[pasteboard% after-reorder] modifies the editor).

If @scheme[before?] is @scheme[#t], then @scheme[snip] was moved before
 @scheme[to-snip], otherwise @scheme[snip] was moved after @scheme[to-snip].

See also @method[pasteboard% can-reorder?] and @method[editor<%>
 on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (after-resize [snip (is-a?/c snip%)]
                         [w (and/c real? (not/c negative?))]
                         [h (and/c real? (not/c negative?))]
                         [resized? any/c])
           void?]{
@methspec{

Called after a given snip is resized (and after the @techlink{display}
 is refreshed; use @method[pasteboard% on-resize] and
 @method[editor<%> begin-edit-sequence] to avoid extra refreshes when
 @method[pasteboard% after-resize] modifies the editor), or after an
 unsuccessful resize attempt was made.

If @scheme[resized?] is not @scheme[#f], the snip was successfully
 resized.

See also @method[pasteboard% can-resize?] and @method[editor<%>
 on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (after-select [snip (is-a?/c snip%)]
                         [on? any/c])
           void?]{

@methspec{

Called after a snip in the pasteboard is selected or deselected. See
 also @method[pasteboard% on-select].  This method is not called after
 selected snip is deleted (and thus de-selected indirectly); see also
 @method[pasteboard% after-delete].

If @scheme[on?] is @scheme[#t], then @scheme[snip] was just selected,
 otherwise @scheme[snip] was just deselected.

See also @method[pasteboard% can-select?] and @method[editor<%>
 on-edit-sequence].

No internals locks are set when this method is called.

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (can-delete? [snip (is-a?/c snip%)])
           boolean?]{

@methspec{

Called before a snip is deleted from the editor.
 If the return value is @scheme[#f], then the
 delete will be aborted.

See also @method[pasteboard% on-delete] and @method[pasteboard%
 after-delete].

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|).

}
@methimpl{

Returns @scheme[#t].

}
}

@defmethod[#:mode pubment 
           (can-insert? [snip (is-a?/c snip%)]
                        [before (or/c (is-a?/c snip%) false/c)]
                        [x real?]
                        [y real?])
           boolean?]{

@methspec{

Called before a snip is inserted from the editor.  If the return value
 is @scheme[#f], then the insert will be aborted.

See also @method[pasteboard% on-insert] and @method[pasteboard%
 after-insert].

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|).

}
@methimpl{

Returns @scheme[#t].

}
}


@defmethod[#:mode pubment 
           (can-interactive-move? [event (is-a?/c mouse-event%)])
           boolean?]{

@methspec{

Called when the user starts interactively dragging snips (the ones
 that are selected; see @method[pasteboard%
 find-next-selected-snip]). All of the selected snips will be
 moved. If @scheme[#f] is returned, the interactive move is
 disallowed. The mouse event that started the move (usually a
 button-down event) is provided.

See also @method[pasteboard% on-interactive-move], @method[pasteboard%
 after-interactive-move], and @method[pasteboard%
 interactive-adjust-move].

}
@methimpl{

Returns @scheme[#t].

}}


@defmethod[#:mode pubment 
           (can-interactive-resize? [snip (is-a?/c snip%)])
           boolean?]{
@methspec{

Called when the user starts interactively resizing a snip (the one
 that is selected; see @method[pasteboard%
 find-next-selected-snip]). If @scheme[#f] is returned, the
 interactive resize is disallowed.

The @scheme[snip] argument is the snip that will be resized.

See also @method[pasteboard% after-interactive-resize],
 @method[pasteboard% after-interactive-resize], and
 @method[pasteboard% interactive-adjust-resize].

}
@methimpl{

Returns @scheme[#t].

}}


@defmethod[#:mode pubment 
           (can-move-to? [snip (is-a?/c snip%)]
                         [x real?]
                         [y real?]
                         [dragging? any/c])
           boolean?]{
@methspec{

Called before a snip is moved in the editor.  If the return value is
 @scheme[#f], then the move will be aborted.

If @scheme[dragging?] is not @scheme[#f], then this move is a
 temporary move for dragging.

See also @method[pasteboard% on-move-to] and @method[pasteboard%
 after-move-to].

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|).

}
@methimpl{

Returns @scheme[#t].

}}


@defmethod[#:mode pubment 
           (can-reorder? [snip (is-a?/c snip%)]
                         [to-snip (is-a?/c snip%)]
                         [before? any/c])
           boolean?]{
@methspec{

Called before a snip is moved in the pasteboard's front-to-back snip
 order.  If the return value is @scheme[#f], then the reordering will
 be aborted.

If @scheme[before?] is @scheme[#t], then @scheme[snip] is to be moved before
 @scheme[to-snip], otherwise @scheme[snip] is to be moved after
 @scheme[to-snip].

See also @method[pasteboard% on-reorder] and @method[pasteboard%
 after-reorder].

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|).

}
@methimpl{

Returns @scheme[#t].

}}


@defmethod[#:mode pubment 
           (can-resize? [snip (is-a?/c snip%)]
                        [w (and/c real? (not/c negative?))]
                        [h (and/c real? (not/c negative?))])
           boolean?]{

@methspec{

Called before a snip is resized in the editor.  If the return value is
 @scheme[#f], then the resize will be aborted.

See also @method[pasteboard% on-resize] and @method[pasteboard%
 after-resize].

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|).

}
@methimpl{

Returns @scheme[#t].

}}

@defmethod[#:mode pubment 
           (can-select? [snip (is-a?/c snip%)]
                        [on? any/c])
           boolean?]{
@methspec{

This method is called before a snip in the pasteboard is selected or
 deselected. If @scheme[#f] is returned, the selection change is
 disallowed. This method is not called when a selected snip is to be
 deleted (and thus de-selected indirectly); see also
 @method[pasteboard% can-delete?].

If @scheme[on?] is @scheme[#t], then @scheme[snip] will be selected,
otherwise @scheme[snip] will be deselected.

See also @method[pasteboard% on-select] and @method[pasteboard%
 after-select].

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|). 

}
@methimpl{

Returns @scheme[#t].

}}


@defmethod*[#:mode override
            ([(change-style [style (or/c (is-a?/c style-delta%) (is-a?/c style<%>) #f) #f]
                            [snip (or/c (is-a?/c snip%) #f) #f])
              void?])]{

Changes the style of @scheme[snip] to a specific style or by applying
 a style delta.  If @scheme[snip] is @scheme[#f], then all currently
 selected snips are changed. If @scheme[style] is @scheme[#f], then 
 the default style is used, according to @method[editor<%> default-style-name].
 
 See also @xmethod[editor<%> change-style].

When a @scheme[style] is provided: @InStyleListNote[@scheme[style]]

}


@defmethod[#:mode override
           (copy-self-to [dest (or/c (is-a?/c text%) (is-a?/c pasteboard%))])
           void?]{

In addition to the default @xmethod[editor<%> copy-self-to] work, the
 dragability, selection visibility state, and scroll step of
 @this-obj[] are installed into @scheme[dest].

}


@defmethod*[([(delete)
              void?]
             [(delete [snip (is-a?/c snip%)])
              void?])]{

Deletes @scheme[snip] when provided, or deletes the currently selected
 snips from the editor when @scheme[snip] is not provided.

@MonitorMethod[@elem{The content of an editor} @elem{the
 system in response to other method
 calls} @elem{@method[pasteboard% on-delete]} @elem{content deletion}]

}


@defmethod[#:mode override 
           (do-copy [time exact-integer?]
                    [extend? any/c])
           void?]{

@methspec{

Called to copy the editor's current selection into the clipboard.
 This method is provided so that it can be overridden by subclasses.
 Do not call this method directly; instead, call @method[editor<%>
 copy].

See @|timediscuss| for a discussion of the @scheme[time] argument. If
 @scheme[time] is outside the platform-specific range of times,
 @|MismatchExn|.

}
@methimpl{

Copies the current selection, extending the current clipboard contexts
 if @scheme[extend?] is true.

}}


@defmethod[#:mode override
           (do-paste [time exact-integer?])
           void?]{
@methspec{

Called to paste the current contents of the clipboard into the editor.
 This method is provided so that it can be overridden by subclasses.
 Do not call this method directly; instead, call @method[editor<%>
 paste].

See @|timediscuss| for a discussion of the @scheme[time] argument. If
 @scheme[time] is outside the platform-specific range of times,
 @|MismatchExn|.

}
@methimpl{

Pastes.

}}


@defmethod[#:mode override
           (do-paste-x-selection [time exact-integer?])
           void?]{
@methspec{

Called to paste the current contents of the X selection under X (or
 the clipboard under Windows and Mac OS X) into the editor.  This
 method is provided so that it can be overridden by subclasses.  Do
 not call this method directly; instead, call @method[editor<%>
 paste-x-selection].

See @|timediscuss| for a discussion of the @scheme[time] argument. If
 @scheme[time] is outside the platform-specific range of times,
 @|MismatchExn|.

}
@methimpl{

Pastes.

}}


@defmethod[(erase)
           void?]{

Deletes all snips from the editor.

See also @method[pasteboard% delete].

}


@defmethod[(find-next-selected-snip [start (or/c (is-a?/c snip%) false/c)])
           (or/c (is-a?/c snip%) false/c)]{

Returns the next selected snip in the editor, starting the search
 after @scheme[start]. (@|seesniporderdiscuss|) If @scheme[start] is @scheme[#f],
 then the search starts with the first snip in the editor (and thus
 returns the first selected snip, if any are selected). If no more
 selected snips are available, or if @scheme[start] is not in the
 pasteboard, @scheme[#f] is returned.

}


@defmethod[(find-snip [x real?]
                      [y real?]
                      [after (or/c (is-a?/c snip%) false/c) #f])
           (or/c (is-a?/c snip%) false/c)]{

Finds the frontmost snip (after a given snip) that intersects a given
 @techlink{location}.  @|seesniporderdiscuss|

The @scheme[x] and @scheme[y] arguments are in editor coordinates. If
 @scheme[after] is not supplied, the frontmost snip at @scheme[x] and
 @scheme[y] is returned, otherwise the frontmost snip behind @scheme[after]
 is returned. If @scheme[after] is a snip that is not in the pasteboard,
 @scheme[#f] is returned.

@|OVD|

}


@defmethod[(get-center) (values real? real?)]{

Returns the center of the pasteboard in pasteboard coordinates.

The first result is the x-coordinate of the center and
the second result is the y-coordinate of the center.

}


@defmethod[(get-dragable)
           boolean?]{

Returns whether snips in the editor can be interactively dragged by
 event handling in @method[pasteboard% on-default-event]: @scheme[#t]
 if dragging is allowed, @scheme[#f] otherwise.  By default, dragging
 is allowed. See also @method[pasteboard% set-dragable].

}

@defmethod[(get-scroll-step)
           (and/c real? (not/c negative?))]{

Gets the editor @techlink{location} offset for each vertical scroll
 position.  See also @method[pasteboard% set-scroll-step].

}


@defmethod[(get-selection-visible)
           boolean?]{

Returns whether selection dots are drawn around the edge of selected
 snips in the pasteboard. By default, selection dots are on. See also
 @method[pasteboard% set-selection-visible].

}


@defmethod*[#:mode extend
            ([(insert [snip (is-a?/c snip%)])
              void?]
             [(insert [snip (is-a?/c snip%)]
                      [before (or/c (is-a?/c snip%) false/c)]
                      [x real?]
                      [y real?])
              void?]
             [(insert [snip (is-a?/c snip%)]
                      [x real?]
                      [y real?])
              void?]
             [(insert [snip (is-a?/c snip%)]
                      [before (or/c (is-a?/c snip%) false/c)])
              void?])]{

Inserts @scheme[snip] at @techlink{location} @math{(@scheme[x],
 @scheme[y])} just in front of
 @scheme[before]. (@|seesniporderdiscuss|) If @scheme[before] is not
 provided or is @scheme[#f], then @scheme[snip] is inserted behind all
 other snips. If @scheme[x] and @scheme[y] are not provided, the snip
 is added at @math{(0, 0)}.

}


@defmethod[(interactive-adjust-mouse [x (box/c real?)]
                                     [y (box/c real?)])
           void?]{

@methspec{

This method is called during interactive dragging and resizing (of the
 currently selected snips; see @method[pasteboard%
 find-next-selected-snip]) to preprocess the current mouse
 @techlink{location} (in editor coordinates).  The snip and actual x
 and y coordinates are passed into the method (boxed); the resulting
 coordinates are used instead of the actual mouse @techlink{location}.

See also 
 @method[pasteboard% interactive-adjust-resize].

}
@methimpl{

A negative value for either @scheme[x] or @scheme[y] is replaced with
 @scheme[0].

}}


@defmethod[(interactive-adjust-move [snip (is-a?/c snip%)]
                                    [x (box/c real?)]
                                    [y (box/c real?)])
           void?]{
@methspec{

This method is called during an interactive move (for each selected
 snip) to preprocess the user-determined snip @techlink{location} for each
 selected snip. The snip and mouse-determined @techlink{location}s (in editor
 coordinates) are passed into the method (boxed); the resulting
 @techlink{location}s are used for graphical feedback to the user during moving.

The actual mouse coordinates are first sent through
 @method[pasteboard% interactive-adjust-mouse] before determining the
 @techlink{location}s passed into this method.

}
@methimpl{

Does nothing.

}}


@defmethod[(interactive-adjust-resize [snip (is-a?/c snip%)]
                                      [width (box/c (and/c real? (not/c negative?)))]
                                      [height (box/c (and/c real? (not/c negative?)))])
           void?]{
@methspec{

This method is called during interactive resizing of a snip to
 preprocess the user-determined snip size. The snip and
 mouse-determined height and width are passed into the method (boxed);
 the resulting height and width are used for graphical feedback to the
 user during resizing.

The actual mouse coordinates are first sent through
 @method[pasteboard% interactive-adjust-mouse] before determining the
 sizes passed into this method.

}
@methimpl{

Does nothing.

}}

@defmethod[(is-selected? [snip (is-a?/c snip%)])
           boolean?]{

Returns @scheme[#t] if a specified snip is currently selected or
 @scheme[#f] otherwise.

}

@defmethod[(lower [snip (is-a?/c snip%)])
           void?]{

Moves the snip one level deeper (i.e., behind one more other snip) in
 the pasteboard's snip order. @|seesniporderdiscuss|

See also @method[pasteboard% raise], @method[pasteboard% set-before],
 and @method[pasteboard% set-after].

}


@defmethod*[([(move [snip (is-a?/c snip%)]
                    [x real?]
                    [y real?])
              void?]
             [(move [x real?]
                    [y real?])
              void?])]{

Moves @scheme[snip] right @scheme[x] pixels and down @scheme[y]
 pixels.  If @scheme[snip] is not provided, then all selected snips
 are moved.

@|OnMoveNote|

}


@defmethod[(move-to [snip (is-a?/c snip%)]
                    [x real?]
                    [y real?])
           void?]{

Moves @scheme[snip] to a given @techlink{location} in the editor.

@|OnMoveNote|

}


@defmethod[(no-selected)
           void?]{

Deselects all selected snips in the editor.

@|OnSelectNote|

}


@defmethod[#:mode override
           (on-default-event [event (is-a?/c mouse-event%)])
           void?]{

Selects, drags, and resizes snips:

@itemize[

@item{Clicking on a snip selects the snip. Shift-clicking extends
the current selection with the snip.}

@item{Clicking in the space between snips drags a selection
box; once the mouse button is released, all snips touching the
box are selected. Shift-clicking extends the current selection
with the new snips.}

@item{Double-clicking on a snip calls
@method[pasteboard% on-double-click].}

@item{Clicking on a selected snip drags the selected snip(s) to a new
@techlink{location}.}

@item{Clicking on a hiliting tab for a selected object resizes the
object.}

]
}


@defmethod[#:mode pubment 
           (on-delete [snip (is-a?/c snip%)])
           void?]{

Called before a snip is deleted from the editor, after
 @method[pasteboard% can-delete?] is called to verify that the
 deletion is allowed. The @method[pasteboard% after-delete] method is
 guaranteed to be called after the delete has completed.

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|). Use @method[pasteboard% after-delete] to
 modify the editor, if necessary.

}


@defmethod[(on-double-click [snip (is-a?/c snip%)]
                            [event (is-a?/c mouse-event%)])
           void?]{
@methspec{

This method is called when the user double-clicks on a snip in the
 editor. The clicked-on snip and event records are passed to the
 method.

}
@methimpl{

If @scheme[snip] accepts events, it is designated as the caret owner
 and all snips in the editor are unselected.

}}


@defmethod[#:mode pubment 
           (on-insert [snip (is-a?/c snip%)]
                      [before (or/c (is-a?/c snip%) false/c)]
                      [x real?]
                      [y real?])
           void?]{


Called before a snip is inserted from the editor, after
 @method[pasteboard% can-insert?] is called to verify that the
 insertion is allowed. The @method[pasteboard% after-insert] method is
 guaranteed to be called after the insert has completed.

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|). Use @method[pasteboard% after-insert] to
 modify the editor, if necessary.

}


@defmethod[#:mode pubment 
           (on-interactive-move [event (is-a?/c mouse-event%)])
           void?]{
@methspec{

Called when the user starts interactively dragging snips (the ones
 that are selected; see @method[pasteboard% find-next-selected-snip]),
 after @method[pasteboard% can-interactive-move?] is called to verify
 that the move is allowed. The @method[pasteboard%
 after-interactive-move] method is guaranteed to be called after the
 move has completed. All of the selected snips will be moved. The
 mouse event that started the move (usually a button-down event) is
 provided.

See also @method[pasteboard% interactive-adjust-move].

}
@methimpl{

Does nothing.

}}

@defmethod[#:mode pubment 
           (on-interactive-resize [snip (is-a?/c snip%)])
           void?]{
@methspec{

Called when the user starts interactively resizing a snip (the one
 that is selected; see @method[pasteboard% find-next-selected-snip]),
 after @method[pasteboard% can-interactive-resize?] is called to
 verify that the resize is allowed. The @method[pasteboard%
 after-interactive-resize] method is guaranteed to be called after the
 resize has completed.

The @scheme[snip] argument is the snip that will be resized. 

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (on-move-to [snip (is-a?/c snip%)]
                       [x real?]
                       [y real?]
                       [dragging? any/c])
           void?]{
@methspec{

Called before a snip is moved in the editor, after @method[pasteboard%
 can-move-to?] is called to verify that the move is allowed. The
 @method[pasteboard% after-move-to] method is guaranteed to be called
 after the move has completed.

If @scheme[dragging?] is not @scheme[#f], then this move is a
 temporary move for dragging.

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|). Use @method[pasteboard% after-move-to] to
 modify the editor, if necessary. See also @method[pasteboard%
 on-interactive-move] and @method[pasteboard%
 interactive-adjust-move].

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (on-reorder [snip (is-a?/c snip%)]
                       [to-snip (is-a?/c snip%)]
                       [before? any/c])
           void?]{
@methspec{

Called before a snip is moved in the pasteboard's front-to-back snip
 order, after @method[pasteboard% can-reorder?] is called to verify
 that the reorder is allowed. The @method[pasteboard% after-reorder]
 method is guaranteed to be called after the reorder has completed.

If @scheme[before?] is @scheme[#t], then @scheme[snip] is to be moved
 before @scheme[to-snip], otherwise @scheme[snip] is to be moved after
 @scheme[to-snip].

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|). Use @method[pasteboard% after-reorder] to
 modify the editor, if necessary.

}
@methimpl{

Does nothing.

}}

@defmethod[#:mode pubment 
           (on-resize [snip (is-a?/c snip%)]
                      [w (and/c real? (not/c negative?))]
                      [h (and/c real? (not/c negative?))])
           void?]{

@methspec{

Called before a snip is resized by the editor, after
 @method[pasteboard% can-resize?] is called to verify that the resize
 is allowed. The @method[pasteboard% after-resize] method is
 guaranteed to be called after the resize has completed.

The editor is internally locked for writing when this method is called (see
 also @|lockdiscuss|). Use
@method[pasteboard% after-resize] to modify the editor, if necessary. 

Note that a snip calls
@method[editor<%> resized], not this method, to notify the pasteboard that the snip resized
 itself.

}
@methimpl{

Does nothing.

}}


@defmethod[#:mode pubment 
           (on-select [snip (is-a?/c snip%)]
                      [on? any/c])
           void?]{
@methspec{

Called before a snip in the pasteboard is selected or deselected,
 after @method[pasteboard% can-select?] is called to verify that the
 selection is allowed. The @method[pasteboard% after-select] method is
 guaranteed to be called after the selection has completed.  This
 method is not called when a selected snip is to be deleted (and thus
 de-selected indirectly); see also @method[pasteboard% on-delete] .

If @scheme[on?] is @scheme[#t], then @scheme[snip] will be selected,
 otherwise @scheme[snip] will be deselected.

The editor is internally locked for writing when this method is called
 (see also @|lockdiscuss|). Use @method[pasteboard% after-select] to
 modify the editor, if necessary.

}
@methimpl{

Does nothing.

}}


@defmethod[(raise [snip (is-a?/c snip%)])
           void?]{

Moves a snip one level shallower (i.e., in front of one more other
 snip) in the pasteboard's snip order. @|seesniporderdiscuss|

See also @method[pasteboard% lower], @method[pasteboard% set-before],
 and @method[pasteboard% set-after].

}


@defmethod[(remove [snip (is-a?/c snip%)])
           void?]{

Removes the specified snip from the editor in a non-undoable manner
 (so the snip is completely free of the pasteboard can be used in
 other editors).

See also @method[pasteboard% delete].

}


@defmethod[(remove-selected [snip (is-a?/c snip%)])
           void?]{

Deselects @scheme[snip] (if it is currently selected) without
 deselecting any other snips.

@|OnSelectNote|

}


@defmethod[(resize [snip (is-a?/c snip%)]
                   [w (and/c real? (not/c negative?))]
                   [h (and/c real? (not/c negative?))])
           boolean?]{

Attempts to resize a given snip. If the snip allows resizing,
 @scheme[#t] is returned, otherwise @scheme[#f] is returned. Using
 this method instead of calling the snip's @method[snip% resize]
 method directly will make the resize undo-able.

}


@defmethod[(set-after [snip (is-a?/c snip%)]
                      [after (or/c (is-a?/c snip%) false/c)])
           void?]{

Changes the depth of @scheme[snip] moving it just behind
 @scheme[after].  If @scheme[after] is @scheme[#f], @scheme[snip] is
 moved to the back. @|seesniporderdiscuss|

See also @method[pasteboard% raise], @method[pasteboard% lower], and
 @method[pasteboard% set-before].

}


@defmethod[(set-before [snip (is-a?/c snip%)]
                       [before (or/c (is-a?/c snip%) false/c)])
           void?]{

Changes the depth of @scheme[snip] moving it just in front of
 @scheme[before].  If @scheme[before] is @scheme[#f], @scheme[snip] is
 moved to the front. @|seesniporderdiscuss|

See also @method[pasteboard% raise], @method[pasteboard% lower], and
 @method[pasteboard% set-after].

}


@defmethod[(set-dragable [allow-drag? any/c])
           void?]{

Sets whether snips in the editor can be interactively dragged by event
 handling in @method[pasteboard% on-default-event]: a true value
 allows dragging, @scheme[#f] disallows dragging.  See also
 @method[pasteboard% get-dragable].

}

@defmethod[(set-scroll-step [stepsize (and/c real? (not/c negative?))])
           void?]{

Sets the editor @techlink{location} offset for each vertical scroll
 position.  See also @method[pasteboard% get-scroll-step].

}

@defmethod[(set-selected [snip (is-a?/c snip%)])
           void?]{

Selects a specified snip (deselecting all others).

@|OnSelectNote|

}

@defmethod[(set-selection-visible [visible? any/c])
           void?]{

Sets whether selection dots are drawn around the edge of selected
 snips in the pasteboard. See also @method[pasteboard%
 get-selection-visible].

}}