.include "coll.h"
.include "game.h"
.include "hsge.h"
.include "obj.h"

.codeseg

.public InvertXSpeed
.public SetCollMode
.public InvertYSpeed
.public OBJ_GetCenterAttrib

.extrn HSGE_SetRoomPtr:proc
.extrn XSIGN:proc

; OBJ_GetCenterAttrib
; ===================

    OBJ_GetCenterAttrib:
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

; OBJ_GetBottomAttrib
; ===================

    OBJ_GetBottomAttrib:
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

; SetCollMode
; ===========

    SetCollMode:
    clc
    jsr     OBJ_GetBottomAttrib
    cmp     #TA_AIR
    bcs     +
    SetPixelCollMode:
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
    bcs     SetTileCollMode
    inc     OBJ_WorldYLo,x
    bne     SetPixelCollMode
    SetTileCollMode:
    lda     OBJ_State,x
    and     #$FD        ; collision mode = per-tile
    sta     OBJ_State,x
    rts

    InvertXSpeed:
    lda     OBJ_SpeedXFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_SpeedX,x
    eor     #$FF
    adc     #0
    rts

    AbsXSpeed:
    lda     OBJ_SpeedX,x
    bmi     InvertXSpeed
    ldy     OBJ_SpeedXFrac,x
    rts

    InvertYSpeed:
    lda     OBJ_SpeedYFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_SpeedY,x
    eor     #$FF
    adc     #0
    rts

    AbsYSpeed:
    lda     OBJ_SpeedY,x
    bmi     InvertYSpeed
    ldy     OBJ_SpeedYFrac,x
    rts
    
    InvertXAccel:
    lda     OBJ_AccelXFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_AccelX,x
    eor     #$FF
    adc     #0
    rts
    
    InvertYAccel:
    lda     OBJ_AccelYFrac,x
    jsr     XSIGN
    tay
    lda     OBJ_AccelY,x
    eor     #$FF
    adc     #0
    rts

.end
