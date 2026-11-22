.include "anim.h"
.include "chr.h"
.include "game.h"
.include "hsge.h"
.include "nes.h"
.include "obj.h"
.include "area2d.h"
.include "fade.h"
.include "palette.h"
.include "ppu.h"
.include "renderer.h"
.include "statusmain.h"
.include "warp.h"

.codeseg

.public ExitStatusScreen
.public StatusMain

; StatusMain
; ==========

.proc StatusMain
    lda     JoyFirst
    and     #btnSTART
    bne     ExitStatusScreen
    rts
.endp
.proc ExitStatusScreen
    jsr     PAL_FadeToBlack
    jsr     ScreenOff
    jsr     Load2DArea
    jsr     RestoreAreaScreen
    jsr     Area2DMain   ; just so objects are drawn during fade-in
    lda     #231
    sta     IRQCount
    jsr     ScreenOn
    jsr     PAL_FadeFromBlack
    lda     #mrArea2DMain
    sta     MainRoutine
    rts
.endp

; RestoreAreaScreen
; =================

.proc RestoreAreaScreen
; restore Area CHR
    lda     ah_AreaCHR
    sta     SelectedCHR
    lda     ah_AreaCHR+1
    sta     SelectedCHR+1
    lda     #CHR_STATUS
    sta     SelectedCHR+3
; restore sprite CHR
    ldx     #23
  - lda     OBJ_Type,x
    bmi     +
    lda     ANIM_Cel,x
    jsr     ANIM_SetCel
  + dex
    bpl     -
; restore Area palette
    lda     ah_pAreaPalette
    ldy     ah_pAreaPalette+1
    jsr     PAL_LoadPalette
    jsr     SetHealthPal
; restore screen settings
    lda     HSGE_Temp2000
    sta     ZPCtrl0
; restore Area screen
    dec     HSGE_MapOfs
    jmp     HSGE_RenderScreen
.endp

.end
