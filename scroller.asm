.include "game.h"
.include "hsge.h"
.include "renderer.h"
.include "scroller.h"

.codeseg

.public HSGE_SetRoomPtr
.public HSGE_CalcRoomOfs
.public HSGE_ScrollLeft
.public HSGE_ScrollRight
.public HSGE_ScrollDown
.public HSGE_ScrollUp

; SetRoomPtr
; ==========
; Sets the room pointer.
; In: A = map index

.proc HSGE_SetRoomPtr
    asl
    tay
    lda     [pMap],y    ; pMap is defined in game.asm
    sta     HSGE_pRoom
    iny
    lda     [pMap],y
    sta     HSGE_pRoom+1
    rts
.endp

; HSGE_CalcRoomOfs
; ================
; Calculates room data (macro) offset from column and row.
; ofs = ((row/4)*8) + (col/4)

.proc HSGE_CalcRoomOfs
    lda     HSGE_RoomCol
    lsr
    lsr
    sta     Temp
    lda     HSGE_RoomRow
    and     #$FC
    asl
    ora     Temp
    sta     HSGE_RoomOfs
    rts
.endp

; HSGE_ScrollRight
; ================
; Attempts to scroll the display one pixel right.
; Out: CF=0 if scroll was performed, 1 otherwise

.proc HSGE_ScrollRight
    lda     HSGE_WorldViewX
    bne     +
    ; at a room border
    ; check if allowed to scroll any further
    ldy     HSGE_WorldViewX+1
    iny
    cpy     MapWidth
    bcc     +
    ; reached end of map, no scroll 4 u (CF=1)
    rts
  + inc     HSGE_WorldViewX
    lda     HSGE_WorldViewX
    bne     +
    ; horizontal page wrap
    inc     HSGE_WorldViewX+1
    ; DELETE objects @ map positions (X-2,Y), (X-2,Y-1), (X-2,Y+1), (X-2,Y+2)
    lda     #0
    sta     ObjLoadQueueXSize
    lda     HSGE_WorldViewX+1
    sec
    sbc     #2  ; X-2
    pha         ; push X-2, we need it more
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_DeleteFarObjects
    pla         ; X-2
    pha
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_DeleteFarObjects
    pla         ; X-2
    pha
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_DeleteFarObjects
    pla         ; X-2
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
    ; LOAD objects @ map positions (X+2,Y), (X+2,Y-1), (X+2,Y+1), (X+2,Y+2)
    lda     HSGE_WorldViewX+1
    clc
    adc     #2  ; X+2
    sta     ObjLoadQueueX
    sta     ObjLoadQueueX+1
    sta     ObjLoadQueueX+2
    sta     ObjLoadQueueX+3
    lda     HSGE_WorldViewY+1
    sta     ObjLoadQueueX+4
    sec
    sbc     #1  ; Y-1
    sta     ObjLoadQueueX+5
    clc
    adc     #2  ; Y+1
    sta     ObjLoadQueueX+6
    clc
    adc     #1  ; Y+2
    sta     ObjLoadQueueX+7
    lda     #4
    sta     ObjLoadQueueXSize
    ;
    lda     HSGE_WorldViewX
  + and     #7
    beq     +       ; time to update nametable?
    clc     ; scroll OK
    rts
  + ldy     HSGE_QueueSize
    lda     #%00000001  ; request update
    sta     HSGE_ScrollQueue,y
    ; check if necessary to update attribute table
    lda     HSGE_WorldViewX
    and     #8
    beq     +
    lda     #%00010001  ; request update
    sta     HSGE_ScrollQueue,y
  + inc     HSGE_QueueSize
    clc     ; scroll OK
    rts
.endp

; HSGE_ScrollLeft
; ===============
; Attempts to scroll the display one pixel right.
; Out: CF=0 if scroll was performed, 1 otherwise

.proc HSGE_ScrollLeft
    lda     HSGE_WorldViewX
    bne     +
    ; horizontal page wrap - check if allowed to scroll any further
    lda     HSGE_WorldViewX+1
    bne     ++  ; continue if not at page 0
    ; reached beginning of map, no scroll 4 u
    sec
    rts
 ++ ; DELETE @ (X+2,Y), (X+2,Y-1), (X+2,Y+1)
    lda     #0
    sta     ObjLoadQueueXSize
    lda     HSGE_WorldViewX+1
    clc
    adc     #2
    pha
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_DeleteFarObjects
    pla
    pha
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_DeleteFarObjects
    pla
    pha
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_DeleteFarObjects
    pla
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
    ; LOAD @ (X-2,Y), (X-2,Y-1), (X-2,Y+1)
    lda     HSGE_WorldViewX+1
    sec
    sbc     #2
    sta     ObjLoadQueueX
    sta     ObjLoadQueueX+1
    sta     ObjLoadQueueX+2
    sta     ObjLoadQueueX+3
    lda     HSGE_WorldViewY+1
    sta     ObjLoadQueueX+4
    sec
    sbc     #1
    sta     ObjLoadQueueX+5
    clc
    adc     #2
    sta     ObjLoadQueueX+6
    clc
    adc     #1
    sta     ObjLoadQueueX+7
    lda     #4
    sta     ObjLoadQueueXSize
    ;
    dec     HSGE_WorldViewX+1
    lda     HSGE_WorldViewX
  + dec     HSGE_WorldViewX
    and     #7
    beq     +       ; time to update nametable?
    clc
    rts
  + ldy     HSGE_QueueSize
    lda     #%00000010  ; request update
    sta     HSGE_ScrollQueue,y
    ; check if necessary to update attribute table
    lda     HSGE_WorldViewX
    and     #8
    bne     +
    lda     #%00100010  ; request update
    sta     HSGE_ScrollQueue,y
  + inc     HSGE_QueueSize
    clc
    rts
.endp

; HSGE_ScrollDown
; ===============
; Attempts to scroll the display one pixel down.
; Out: CF=0 if scroll was performed, 1 otherwise

.proc HSGE_ScrollDown
    lda     HSGE_WorldViewY
    cmp     #16
    bne     +
    ; check if allowed to scroll any further
    ldy     HSGE_WorldViewY+1
    iny
    cpy     MapHeight
    bcc     +
    ; reached end of map, no scroll 4 u
    rts
  + inc     HSGE_ScrollY
    lda     HSGE_ScrollY
    cmp     #240
    bne     +
    ; screen wrap
    lda     #0
    sta     HSGE_ScrollY
    lda     ZPCtrl0
    eor     #$02    ; switch to other nametable
    sta     ZPCtrl0
  + inc     HSGE_WorldViewY
    lda     HSGE_WorldViewY
    bne     +
    ; vertical page wrap
    inc     HSGE_WorldViewY+1
    ; DELETE @ (X,Y-2), (X-1,Y-2), (X+1,Y-2), (X+2,Y-2)
    lda     #0
    sta     ObjLoadQueueYSize
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    dey
    dey
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    dey
    tya
    ldy     HSGE_WorldViewY+1
    dey
    dey
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    iny
    tya
    ldy     HSGE_WorldViewY+1
    dey
    dey
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    iny
    iny
    tya
    ldy     HSGE_WorldViewY+1
    dey
    dey
    jsr     HSGE_DeleteFarObjects
    ; LOAD @ (X,Y+2), (X-1,Y+2), (X+1,Y+2), (X+2,Y+2)
    lda     HSGE_WorldViewX+1
    sta     ObjLoadQueueY
    sec
    sbc     #1
    sta     ObjLoadQueueY+1
    clc
    adc     #2
    sta     ObjLoadQueueY+2
    clc
    adc     #1
    sta     ObjLoadQueueY+3
    lda     HSGE_WorldViewY+1
    clc
    adc     #2
    sta     ObjLoadQueueY+4
    sta     ObjLoadQueueY+5
    sta     ObjLoadQueueY+6
    sta     ObjLoadQueueY+7
    lda     #4
    sta     ObjLoadQueueYSize
    ;
    lda     HSGE_WorldViewY
  + and     #7
    beq     +       ; time to update nametable?
    clc
    rts
  + ldy     HSGE_QueueSize
    lda     #%00000100  ; request update
    sta     HSGE_ScrollQueue,y
    ; check if necessary to update attribute table
    lda     HSGE_WorldViewY
    and     #8
    beq     +
    lda     #%01000100  ; request update
    sta     HSGE_ScrollQueue,y
  + inc     HSGE_QueueSize
    clc
    rts
.endp

; HSGE_ScrollUp
; =============
; Attempts to scroll the display one pixel up.
; Out: CF=0 if scroll was performed, 1 otherwise

.proc HSGE_ScrollUp
    lda     HSGE_WorldViewY
    bne     +
    ; vertical page wrap - check if allowed to scroll any further
    lda     HSGE_WorldViewY+1
    bne     ++
    ; reached beginning of map, no scroll 4 u
    sec
    rts
 ++ ; DELETE @ (X,Y+2), (X-1,Y+2), (X+1,Y+2), (X+2,Y+2)
    lda     #0
    sta     ObjLoadQueueYSize
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    dey
    tya
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    iny
    tya
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
    ldy     HSGE_WorldViewX+1
    iny
    iny
    tya
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_DeleteFarObjects
; LOAD @ (X,Y-2), (X-1,Y-2), (X+1, Y-2), (X+2,Y-2)
    lda     HSGE_WorldViewX+1
    sta     ObjLoadQueueY
    sec
    sbc     #1
    sta     ObjLoadQueueY+1
    clc
    adc     #2
    sta     ObjLoadQueueY+2
    clc
    adc     #1
    sta     ObjLoadQueueY+3
    lda     HSGE_WorldViewY+1
    sec
    sbc     #2
    sta     ObjLoadQueueY+4
    sta     ObjLoadQueueY+5
    sta     ObjLoadQueueY+6
    sta     ObjLoadQueueY+7
    lda     #4
    sta     ObjLoadQueueYSize
    ;
    dec     HSGE_WorldViewY+1
    lda     HSGE_WorldViewY
  + dec     HSGE_WorldViewY
    ldy     HSGE_ScrollY
    bne     +
    ; screen wrap
    ldy     #240
    sty     HSGE_ScrollY
    pha
    lda     ZPCtrl0
    eor     #$02    ; switch to other nametable
    sta     ZPCtrl0
    pla
  + dec     HSGE_ScrollY
    and     #7
    beq     +       ; time to update nametable?
    clc
    rts
  + ldy     HSGE_QueueSize
    lda     #%00001000  ; request update
    sta     HSGE_ScrollQueue,y
    ; check if necessary to update attribute table
    lda     HSGE_WorldViewY
    and     #8
    bne     +
    lda     #%10001000  ; request update
    sta     HSGE_ScrollQueue,y
  + inc     HSGE_QueueSize
    clc
    rts
.endp

.end
