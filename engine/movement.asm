.include "engine/coll.h"
.include "game.h"
.include "engine/hsge.h"
.include "engine/obj.h"
.include "common/math.h"
.include "engine/movement.h"
.include "engine/scroller.h"
.include "engine/warp.h"

.codeseg

.public InvertXSpeed
.public SetCollMode
.public InvertYSpeed
.public OBJ_GetCenterAttrib

; OBJ_GetCenterAttrib
; ===================

.proc OBJ_GetCenterAttrib
    lda     OBJ_MapOfs,x
    jsr     HSGE_SetRoomPtr
    lda     OBJ_WorldXLo,x
    lsr
    lsr
    lsr
    lsr
    pha
    and     #1
    sta     Index2
    pla
    lsr
    sta     Index       ; horizontal room offset (0..7)
    lda     OBJ_WorldYLo,x
    lsr
    lsr
    pha
    and     #$38
    ora     Index
    sta     Index
    pla
    lsr
    and     #2
    ora     Index2
    sta     Index2  ; attribute index (0..3)
    lda     #0
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
    lda     [pData],y
    rts
.endp

; OBJ_GetBottomAttrib
; ===================

.proc OBJ_GetBottomAttrib
    php
    lda     OBJ_WorldXLo,x
    lsr
    lsr
    lsr
    lsr
    pha
    and     #1
    sta     Index2
    pla
    lsr
    sta     Index       ; horizontal room offset (0..7)
    ldy     OBJ_MapOfs,x
    lda     OBJ_WorldYLo,x
    plp
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
    tya     ; map offset
    jsr     HSGE_SetRoomPtr
    lda     #0
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
    lda     [pData],y
    rts
.endp

; SetCollMode
; ===========

.proc SetCollMode
    clc
    jsr     OBJ_GetBottomAttrib
    cmp     #TA_AIR
    bcs     +
    @@SetPixelCollMode:
    asl
    asl
    asl
    asl
    asl
    sta     OBJ_CollIndex,x
    lda     OBJ_State,x
    ora     #$02        ; collision mode = per-pixel
    sta     OBJ_State,x
    rts
  + sec
    jsr     OBJ_GetBottomAttrib
    cmp     #TA_AIR
    bcs     @@SetTileCollMode
    inc     OBJ_WorldYLo,x
    bne     @@SetPixelCollMode
    @@SetTileCollMode:
    lda     OBJ_State,x
    and     #$FD        ; collision mode = per-tile
    sta     OBJ_State,x
    rts
.endp

.proc InvertXSpeed
    lda     OBJ_SpeedXFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_SpeedX,x
    eor     #$FF
    adc     #0
    rts
.endp

.proc InvertYSpeed
    lda     OBJ_SpeedYFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_SpeedY,x
    eor     #$FF
    adc     #0
    rts
.endp

.end
