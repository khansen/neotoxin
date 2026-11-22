.include "engine/coll.h"
.include "game.h"
.include "engine/hsge.h"
.include "engine/obj.h"
.include "engine/bgcollision.h"
.include "common/math.h"
.include "engine/movement.h"
.include "engine/scroller.h"
.include "engine/warp.h"

.codeseg

.public OBJ_CheckMoveDown
.public MoveXDir
.public OBJ_CheckMoveLeft
.public OBJ_CheckMoveRight
.public OBJ_CheckMoveUp
.public MoveObject

.proc MoveObject
    lda     #$00
    sta     CollStat        ; reset collision flags
    lda     OBJ_State,x
    bpl     MoveXDir
    rts
.endp
.proc MoveXDir
    lda     OBJ_SpeedX,x
    ora     OBJ_SpeedXFrac,x
    beq     @@MoveYDir
    lda     OBJ_SpeedX,x
    bmi     +               ; if (SpeedX > 0)
    jsr     OBJ_MoveRight   ;     MoveRight();
    jmp     @@MoveYDir
  + jsr     OBJ_MoveLeft    ; else MoveLeft();
    @@MoveYDir:
    lda     OBJ_SpeedY,x
    ora     OBJ_SpeedYFrac,x
    beq     @@UpdateSpeed
    lda     OBJ_SpeedY,x
    bmi     +               ; if (SpeedY > 0)
    jsr     OBJ_MoveDown    ;     MoveDown();
    jmp     @@UpdateSpeed
  + jsr     OBJ_MoveUp      ; else MoveUp();
    @@UpdateSpeed:
; x speed
    lda     OBJ_SpeedXFrac,x
    clc
    adc     OBJ_AccelXFrac,x
    sta     OBJ_SpeedXFrac,x
    lda     OBJ_SpeedX,x
    adc     OBJ_AccelX,x
    sta     OBJ_SpeedX,x
; y speed
    lda     OBJ_SpeedYFrac,x
    clc
    adc     OBJ_AccelYFrac,x
    sta     OBJ_SpeedYFrac,x
    lda     OBJ_SpeedY,x
    adc     OBJ_AccelY,x
    bmi     +
    cmp     #6
    bcc     ++
    lda     #5
    bne     ++
  + cmp     #$FB
    bcs     ++
    lda     #$FB
 ++ sta     OBJ_SpeedY,x
    rts
.endp

; OBJ_MoveLeft
; ============

.proc OBJ_MoveLeft
; invert speed, to get positive # of pixels
    lda     OBJ_SpeedXFrac,x
    jsr     XSIGN
    lda     OBJ_SpeedX,x
    eor     #$FF
    adc     #0
    beq     ++
; A contains # of pixels to attempt to move
    jsr     OBJ_MoveItLeft
    bcs     +
 ++ lda     OBJ_SpeedXFrac,x
    beq     +
    adc     OBJ_WorldXFrac,x
    bcs     ++
    pha
    lda     #1
    jsr     OBJ_MoveItLeft
    pla
    bcs     +
 ++ sta     OBJ_WorldXFrac,x
  + rts
.endp

.proc OBJ_MoveItLeft
    sta     Count           ; # of pixels to move
    lda     OBJ_State,x
    and     #$02            ; collision mode
    bne     @@OBJ_PixLoopLeft
    jmp     @@OBJ_MovePixelLeft

; pixel-perfect collision

    @@OBJ_PixLoopLeft:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     ++              ; skip if yes
    lda     OBJ_SpeedY,x
    bmi     ++

    lda     OBJ_WorldXLo,x
    and     #$1F
    cmp     #$1F
    bne     +
    and     #$1E
  + ora     OBJ_CollIndex,x
    tay
    lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x   ; object's reach downwards
    and     #$1F
    eor     #$1F
    sec
    sbc     HeightArray,y
    bmi     +
    cmp     #$02
    bcs     ++
; object made impact with ground
  + lda     OBJ_AccelY,x
    ora     OBJ_AccelYFrac,x
    bne     +
    lda     HeightArray,y
    cmp     HeightArray+1,y
    bcc     ++
    beq     ++
  + lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x
    and     #$1F
    jsr     XSIGN
    clc
    adc     #$1F
    clc
    adc     OBJ_WorldYLo,x
    bcc     +
    pha
    inc     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    clc
    adc     MapWidth
    sta     OBJ_MapOfs,x
    pla
  + sec
    sbc     HeightArray,y
    sta     OBJ_WorldYLo,x
    bcs     +
    dec     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    sec
    sbc     MapWidth
    sta     OBJ_MapOfs,x

  + lda     CollStat
    ora     #COLL_PIXEL
    sta     CollStat

 ++ lda     OBJ_WorldXLo,x
    bne     +
    dec     OBJ_WorldXHi,x
    dec     OBJ_MapOfs,x
  + dec     OBJ_WorldXLo,x
    and     #$1F
    bne     +
    jsr     SetCollMode
  + dec     Count
    beq     +
    jmp     @@OBJ_PixLoopLeft
  + clc     ; move was OK
    rts

; non-pixel-perfect collision

    @@OBJ_MovePixelLeft:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     +               ; skip if yes
    lda     OBJ_WorldXLo,x
    sec
    sbc     OBJ_RangeX,x   ; object's reach leftwards
    and     #$0F            ; object at a 16-pixel tile boarder?
    bne     +               ; branch if not (move=OK)
    jsr     OBJ_CheckMoveLeft
    bcc     +               ; continue if moving is possible
  - lda     CollStat
    ora     #COLL_LEFT
    sta     CollStat
    sec     ; move was NOT OK
    rts
  + lda     OBJ_WorldXLo,x
    bne     +
    lda     OBJ_WorldXHi,x
    beq     -               ; can't move off the map!
    dec     OBJ_WorldXHi,x
    dec     OBJ_MapOfs,x
  + lda     OBJ_WorldXLo,x
    dec     OBJ_WorldXLo,x  ; move object one pixel left       
    and     #$1F
    bne     +
    jsr     SetCollMode
  + dec     Count           ; moved desired amount?
    bne     @@OBJ_MovePixelLeft   ; if not, attempt to move another pixel
    clc     ; move was OK
    rts
.endp

; OBJ_CheckMoveLeft
; =================

.proc OBJ_CheckMoveLeft
    lda     OBJ_State,x
    and     #$02            ; collision mode
    beq     +               ; only perform crash detection if mode=per-tile
    clc
    rts
  + ldy     OBJ_MapOfs,x
    lda     OBJ_WorldXLo,x
    clc
    sbc     OBJ_RangeX,x
    bcs     +
    dey     ; horizontal room wrap
    jmp     +
.endp

; OBJ_CheckMoveRight
; ==================

.proc OBJ_CheckMoveRight
    lda     OBJ_State,x
    and     #$02            ; collision mode
    beq     ++              ; only perform crash detection if mode=per-tile
    clc
    rts
 ++ ldy     OBJ_MapOfs,x
    lda     OBJ_WorldXLo,x
    sec
    adc     OBJ_RangeX,x
    bcc     +
    iny     ; horizontal room wrap
  + lsr
    lsr
    lsr
    lsr
    pha
    lsr
    sta     Index    ; horizontal room offset (0..7)
    pla
    and     #1
    sta     Index2   ; horizontal 2x2 block selector (0=left, 1=right)
    lda     OBJ_WorldYLo,x
    sec
    sbc     OBJ_RangeY,x
    bcs     +
    ; vertical room wrap
    pha
    tya
    sec
    sbc     MapWidth
    tay
    pla
  + lsr
    lsr
    pha
    and     #$38
    ora     Index   ; start room index
    sta     Index
    pla
    lsr
    lsr
    sta     Temp    ; start row (0..15)
    and     #1      ; vertical 2x2 block selector (0=top, 1=bottom)
    asl
    ora     Index2
    sta     Index2  ; start attribute index (0..3)
    lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x
    ror
    lsr
    lsr
    lsr             ; end row (0..15)
    sec
    sbc     Temp
    and     #$0F
    sta     Count2  ; # of rows to scan - 1
    tya     ; start map offset
    sta     Index4
    jsr     HSGE_SetRoomPtr
  - lda     #0
    sta     pData+1
    ldy     Index
    lda     [HSGE_pRoom],y
    asl
    rol     pData+1
    asl
    rol     pData+1
    adc     ah_pMacroStateTable
    sta     pData
    lda     pData+1
    adc     ah_pMacroStateTable+1
    sta     pData+1
    ldy     Index2
 -- lda     [pData],y     ; get tile state for one 2x2 tile sector
    sta     Temp
    cmp     #TA_SOLID
    bcc     +
    rts         ; exit with CF=1 (crash)
  + dec     Count2
    bmi     +
    tya
    adc     #2
    tay
    cmp     #4
    bcc     --
    lda     Index
    adc     #7          ; next room row
    cmp     #64
    bcc     ++
    ; room wrap
    pha
    lda     Index4
    clc
    adc     MapWidth
    jsr     HSGE_SetRoomPtr
    pla
    and     #7          ; room row = 0
 ++ sta     Index
    lda     Index2
    and     #1          ; attrib row = 0
    sta     Index2
    bpl     -           ; branch always
  + clc
    rts     ; exit with CF=0 (no crash)
.endp

;-----------------------------------------------------------------------------

HeightArray:
; 45 deg., left-right
.db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32
; 45 deg., right-left
.db 32,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
; 30 deg., left-right
.db 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,16
; 30 deg., right-left
.db 16,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0
; 30 deg., left-right
.db 16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,30,30,31,32
; 30 deg., right-left
.db 32,31,30,30,29,29,28,28,27,27,26,26,25,25,24,24,23,23,22,22,21,21,20,20,19,19,18,18,17,17,16,16

; OBJ_MoveRight
; =============

.proc OBJ_MoveRight
    beq     ++
    jsr     OBJ_MoveItRight
    bcs     +
 ++ lda     OBJ_SpeedXFrac,x
    beq     +
    adc     OBJ_WorldXFrac,x
    bcc     ++
    pha
    lda     #1
    jsr     OBJ_MoveItRight
    pla
    bcs     +
 ++ sta     OBJ_WorldXFrac,x
  + rts
.endp

.proc OBJ_MoveItRight
    sta     Count
    lda     OBJ_State,x
    and     #$02
    bne     @@OBJ_PixLoopRight
    jmp     @@OBJ_MovePixelRight

    @@OBJ_PixLoopRight:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     ++              ; skip if yes
    lda     OBJ_SpeedY,x
    bmi     ++

    lda     OBJ_WorldXLo,x
    and     #$1F
    bne     +
    ora     #$01
  + ora     OBJ_CollIndex,x
    tay
    lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x   ; object's reach downwards
    and     #$1F
    eor     #$1F
    sec
    sbc     HeightArray,y
    bmi     +
    cmp     #$02
    bcs     ++
; object made impact with ground
  + lda     OBJ_AccelY,x
    ora     OBJ_AccelYFrac,x
    bne     +
    lda     HeightArray,y
    cmp     HeightArray-1,y
    bcc     ++
    beq     ++
  + lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x
    and     #$1F
    jsr     XSIGN
    clc
    adc     #$1F
    clc
    adc     OBJ_WorldYLo,x
    bcc     +
    pha
    inc     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    clc
    adc     MapWidth
    sta     OBJ_MapOfs,x
    pla
  + sec
    sbc     HeightArray,y
    sta     OBJ_WorldYLo,x
    bcs     +
    dec     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    sec
    sbc     MapWidth
    sta     OBJ_MapOfs,x

  + lda     CollStat
    ora     #COLL_PIXEL
    sta     CollStat

 ++ inc     OBJ_WorldXLo,x
    bne     +
    inc     OBJ_WorldXHi,x
    inc     OBJ_MapOfs,x
  + lda     OBJ_WorldXLo,x
    and     #$1F
    bne     +
    jsr     SetCollMode
  + dec     Count
    beq     +
    jmp     @@OBJ_PixLoopRight
  + clc     ; move was OK
    rts

    @@OBJ_MovePixelRight:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     +               ; skip if yes
    lda     OBJ_WorldXLo,x
    sec
    adc     OBJ_RangeX,x   ; object's reach rightwards
    and     #$0F            ; object at a tile border?
    bne     +               ; branch if not (move=OK)
    jsr     OBJ_CheckMoveRight
    bcc     +               ; continue if moving is possible
  - lda     CollStat
    ora     #COLL_RIGHT
    sta     CollStat
    sec     ; move was NOT OK
    rts
  + inc     OBJ_WorldXLo,x  ; move object one pixel to the right
    bne     +
    ldy     MapWidth
    dey
    tya
    cmp     OBJ_WorldXHi,x  ; about to move off map?
    bne     ++
    dec     OBJ_WorldXLo,x  ; can't allow that
    bne     -
 ++ inc     OBJ_WorldXHi,x
    inc     OBJ_MapOfs,x
  + lda     OBJ_WorldXLo,x
    and     #$1F
    bne     +
    jsr     SetCollMode
  + dec     Count           ; moved desired amount?
    bne     @@OBJ_MovePixelRight  ; if not, attempt to move another pixel
    clc     ; move was OK
    rts
.endp

;-----------------------------------------------------------------------------

; OBJ_MoveUp
; ==========

.proc OBJ_MoveUp
    lda     OBJ_SpeedYFrac,x
    jsr     XSIGN
    lda     OBJ_SpeedY,x
    eor     #$FF
    adc     #0
    beq     ++
    jsr     OBJ_MoveItUp
    bcs     +
 ++ lda     OBJ_SpeedYFrac,x
    beq     +
    adc     OBJ_WorldYFrac,x
    bcs     ++
    pha
    lda     #1
    jsr     OBJ_MoveItUp
    pla
    bcs     +
 ++ sta     OBJ_WorldYFrac,x
  + rts
.endp

.proc OBJ_MoveItUp
    sta     Count
    @@MovePixelUp:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     +               ; skip if yes
    lda     OBJ_WorldYLo,x
    sec
    sbc     OBJ_RangeY,x   ; object's reach upwards
    and     #$0F
    bne     +               ; branch if not (move=OK)
    jsr     OBJ_CheckMoveUp
    bcc     +               ; continue if moving is possible
  - lda     CollStat
    ora     #COLL_UP
    sta     CollStat
    sec     ; move was not OK
    rts
  + lda     OBJ_WorldYLo,x
    bne     +
    lda     OBJ_WorldYHi,x
    beq     -
    dec     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    sec
    sbc     MapWidth
    sta     OBJ_MapOfs,x
  + lda     OBJ_WorldYLo,x
    dec     OBJ_WorldYLo,x  ; move object one pixel up
    clc
    adc     OBJ_RangeY,x
    and     #$1F
    bne     +
    lda     OBJ_State,x
    and     #$FD            ; collision mode = per-tile
    sta     OBJ_State,x
  + dec     Count           ; moved desired amount?
    bne     @@MovePixelUp     ; if not, attempt to move another pixel
    clc     ; move was OK
    rts
.endp

; OBJ_CheckMoveUp
; ===============

.proc OBJ_CheckMoveUp
    ldy     OBJ_MapOfs,x
    lda     OBJ_WorldXLo,x
    sec
    sbc     OBJ_RangeX,x
    bcs     +
    dey     ; horizontal room wrap
  + lsr
    lsr
    lsr
    lsr
    sta     Temp    ; start column (0..15)
    pha
    lsr
    sta     Index    ; horizontal room offset (0..7)
    pla
    and     #1
    sta     Index2   ; horizontal 2x2 block selector (0=left, 1=right)
    lda     OBJ_WorldYLo,x
    clc
    sbc     OBJ_RangeY,x
    bcs     +
    ; vertical room wrap
    pha
    tya
    sec
    sbc     MapWidth
    tay
    pla
  + lsr
    lsr
    pha
    and     #$38
    ora     Index   ; start room index
    sta     Index
    pla
    lsr
    and     #2      ; vertical 2x2 block selector
    ora     Index2
    sta     Index2  ; start attribute index (0..3)
    lda     OBJ_WorldXLo,x
    clc
    adc     OBJ_RangeX,x
    ror
    lsr
    lsr
    lsr             ; end column (0..15)
    sec
    sbc     Temp
    and     #$0F
    sta     Count2  ; # of columns to scan - 1
    tya     ; start map offset
    sta     Index4
    jsr     HSGE_SetRoomPtr
  - lda     #0
    sta     pData+1
    ldy     Index
    lda     [HSGE_pRoom],y
    asl
    rol     pData+1
    asl
    rol     pData+1
    adc     ah_pMacroStateTable
    sta     pData
    lda     pData+1
    adc     ah_pMacroStateTable+1
    sta     pData+1
    ldy     Index2
 -- lda     [pData],y     ; get tile state for one 2x2 tile sector
    sta     Temp
    cmp     #TA_SOLID
    bcc     +
    rts         ; exit with CF=1 (crash)
  + dec     Count2
    bmi     +
    iny
    tya
    lsr
    bcs     --
    inc     Index
    lda     Index
    and     #7
    bne     ++
    ; room wrap
    lda     Index
    sec
    sbc     #8
    sta     Index
    lda     Index4
    clc
    adc     #1
    jsr     HSGE_SetRoomPtr
 ++ lda     Index2
    and     #2          ; attrib column = 0
    sta     Index2
    bpl     -           ; branch always
  + clc
    rts     ; exit with CF=0 (no crash)
.endp

;-----------------------------------------------------------------------------

; OBJ_MoveDown
; ============

.proc OBJ_MoveDown
    beq     ++  ; skip if no full pixels to move
    jsr     OBJ_MoveItDown
    bcs     +   ; exit if can't move any further
 ++ lda     OBJ_SpeedYFrac,x
    beq     +
    adc     OBJ_WorldYFrac,x
    bcc     ++
    pha
    lda     #1
    jsr     OBJ_MoveItDown
    pla
    bcs     +
 ++ sta     OBJ_WorldYFrac,x
  + rts
.endp

.proc OBJ_MoveItDown
    sta     Count           ; desired # of pixels to move
    @@OBJ_MovePixelDown:
    lda     OBJ_State,x
    and     #$04            ; ignore collision?
    bne     +               ; skip if yes
    lda     OBJ_WorldYLo,x
    sec
    adc     OBJ_RangeY,x   ; object's reach downwards
    and     #$0F            ; object at a tile border?
    bne     ++              ; branch if not (move=OK)
    jsr     OBJ_CheckMoveDown
    bcc     ++              ; continue if moving is possible
  - lda     CollStat
    ora     #COLL_DOWN
    sta     CollStat
    sec     ; move not OK
    rts
 ++ lda     OBJ_State,x
    and     #$02            ; collision mode
    beq     +               ; skip if mode=per-tile
    jsr     Pixxx
    bcs     -
  + inc     OBJ_WorldYLo,x  ; move object one pixel down
    bne     +
    ; page wrap
    ldy     MapHeight
    dey
    tya
    cmp     OBJ_WorldYHi,x
    bne     ++
    dec     OBJ_WorldYLo,x
    bne     -
 ++ inc     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    clc
    adc     MapWidth
    sta     OBJ_MapOfs,x
  + lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x
    and     #$0F            ; at a 32-pixel (macro) border?
    bne     +               ; skip if not
    jsr     SetCollMode
  + dec     Count           ; moved desired amount?
    bne     @@OBJ_MovePixelDown ; if not, attempt to move another pixel
    clc     ; move was OK
    rts
.endp

; OBJ_CheckMoveDown
; =================

.proc OBJ_CheckMoveDown
    lda     OBJ_State,x
    and     #$02        ; collision mode
    beq     +           ; jump if mode=per-tile
.endp
; pixel-perfect collision detection
.proc Pixxx
    lda     OBJ_WorldXLo,x
    and     #$1F
    ora     OBJ_CollIndex,x
    tay
    lda     OBJ_WorldYLo,x
    clc
    adc     OBJ_RangeY,x   ; object's reach downwards
    and     #$1F
    eor     #$1F
    sec
    sbc     HeightArray,y
    bmi     ++
    beq     ++
    clc
    rts
 ++ sec
    rts

    ; non-pixel-perfect collision detection
  + ldy     OBJ_MapOfs,x
    lda     OBJ_WorldXLo,x
    sec
    sbc     OBJ_RangeX,x
    bcs     +
    dey     ; horizontal room wrap
  + lsr
    lsr
    lsr
    lsr
    sta     Temp    ; start column (0..15)
    pha
    lsr
    sta     Index    ; horizontal room offset (0..7)
    pla
    and     #1
    sta     Index2   ; horizontal 2x2 block selector (0=left, 1=right)
    lda     OBJ_WorldYLo,x
    sec
    adc     OBJ_RangeY,x
    bcc     +
    ; vertical room wrap
    pha
    tya
    clc
    adc     MapWidth
    tay
    pla
  + lsr
    lsr
    pha
    and     #$38
    ora     Index   ; start room index
    sta     Index
    pla
    lsr
    and     #2      ; vertical 2x2 block selector
    ora     Index2
    sta     Index2  ; start attribute index (0..3)
    lda     OBJ_WorldXLo,x
    clc
    adc     OBJ_RangeX,x
    ror
    lsr
    lsr
    lsr             ; end column (0..15)
    sec
    sbc     Temp
    and     #$0F
    sta     Count2  ; # of columns to scan - 1
    tya     ; start map offset
    sta     Index4
    jsr     HSGE_SetRoomPtr
  - lda     #0
    sta     pData+1
    ldy     Index
    lda     [HSGE_pRoom],y
    asl
    rol     pData+1
    asl
    rol     pData+1
    adc     ah_pMacroStateTable
    sta     pData
    lda     pData+1
    adc     ah_pMacroStateTable+1
    sta     pData+1
    ldy     Index2
 -- lda     [pData],y     ; get tile state for one 2x2 tile sector
    sta     Temp
    cmp     #TA_SOLIDONTOP
    bcc     +
    rts         ; exit with CF=1 (crash)
  + dec     Count2
    bmi     +
    iny
    tya
    lsr
    bcs     --
    inc     Index
    lda     Index
    and     #7
    bne     ++
    ; room wrap
    lda     Index
    sec
    sbc     #8
    sta     Index
    lda     Index4
    clc
    adc     #1
    jsr     HSGE_SetRoomPtr
 ++ lda     Index2
    and     #2          ; attrib column = 0
    sta     Index2
    bpl     -           ; branch always
  + clc
    rts     ; exit with CF=0 (no crash)
.endp

.end
