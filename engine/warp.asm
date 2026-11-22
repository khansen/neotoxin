.include "game.h"
.include "engine/obj.h"
.include "sound/rnme.h"
.include "engine/area2d.h"
.include "common/fade.h"
.include "common/mmc3.h"
.include "common/ppu.h"
.include "engine/warp.h"
.include "area/areahdrs.h"

.codeseg

.public SetSavePtr
.public SetupWarp
.public ExecWarp
.public Load2DArea

; SetSavePtr
; ==========

.proc SetSavePtr
    lda     SaveSlot
    asl
    asl
    asl
    asl
    asl
    asl
    sta     pData
    lda     #0
    rol
    ora     #>SAVE_SLOTS    ; 64 (sizeof(save_slot)) bytes per slot
    sta     pData+1
    rts
.endp

; SetupWarp
; =========

.proc SetupWarp
    sta     WarpType
    lda     OBJ_Var0,x
    ldy     OBJ_Var1,x
    bmi     @@WarpToScript
    sty     CurrentWarp
    pha
    and     #$1F    ; section in lower 5 bits
    sta     CurrentSection
    pla             ; area in upper 3 bits
    lsr
    lsr
    lsr
    lsr
    lsr
    sta     CurrentArea
    lda     #mrExecWarp
    sta     MainRoutine
    jmp     +
    @@WarpToScript:
    jsr     LoadScript
  + stx     Index
    jsr     PAL_FadeToBlack
    ldx     Index
    rts
.endp

; Load2DArea
; ==========

.proc Load2DArea
; load the current Area's header
    lda     CurrentArea
    jsr     Load2DAreaHdr
; load Area's ROM bank
    lda     ah_AreaBank
    jsr     SetBank
; set the current area section
    lda     CurrentSection
    jmp     SetAreaSection
.endp

; ExecWarp
; ========

.proc ExecWarp
    ;;
    lda     OBJ_State
    and     #1
    sta     $7FFF
    ;;
    jsr     Load2DArea
; get offset of warp data
    lda     CurrentWarp
    asl
    tay
; read the data
    lda     [p2DWarps],y
    and     #$0F
    sta     AreaStartX  ; start X position on map
    lda     [p2DWarps],y
    lsr
    lsr
    lsr
    lsr
    sta     AreaStartY  ; start Y position on map
    iny
    lda     [p2DWarps],y
    sta     PlayerStart ; player's position in map room
    lda     #mrArea2DInit
    sta     MainRoutine
    rts

; SetAreaSection
; ==============

    SetAreaSection:
    asl
    asl
    asl
    tay
    lda     [ah_pMaps],y
    sta     MapWidth
    iny
    lda     [ah_pMaps],y
    sta     MapHeight
    iny
    lda     [ah_pMaps],y
    sta     pMap
    iny
    lda     [ah_pMaps],y
    sta     pMap+1
    iny
    lda     [ah_pMaps],y
    sta     p2DWarps
    iny
    lda     [ah_pMaps],y
    sta     p2DWarps+1
    iny
    lda     [ah_pMaps],y
    cmp     RNME_LastTune
    beq     +   ; don't retrig tune if it's already playing
    sta     RNME_LoadTune
  + rts
.endp

.end
