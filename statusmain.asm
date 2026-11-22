.include "anim.h"
.include "chr.h"
.include "game.h"
.include "hsge.h"
.include "nes.h"
.include "obj.h"

.codeseg

.public ExitStatusScreen
.public StatusMain

.extrn PAL_FadeToBlack:proc
.extrn ScreenOff:proc
.extrn Load2DArea:proc
.extrn Area2DMain:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn ANIM_SetCel:proc
.extrn PAL_LoadPalette:proc
.extrn SetHealthPal:proc
.extrn HSGE_RenderScreen:proc

; StatusMain
; ==========

    StatusMain:
    lda     JoyFirst
    and     #btnSTART
    bne     ExitStatusScreen
    rts
    ExitStatusScreen:
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

; RestoreAreaScreen
; =================

    RestoreAreaScreen:
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

.end
