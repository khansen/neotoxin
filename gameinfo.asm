.include "game.h"

.codeseg

.public GameInfoInit
.public GameInfoInit2
.public GameInfoMain

.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn PAL_SetBlackPalette:proc
.extrn GameInfoData:label
.extrn WriteROMPPUString:proc
.extrn StatusScreenPal:label
.extrn PAL_LoadPalette:proc
.extrn StatusScreenCHR:label
.extrn LoadCHR:proc
.extrn SetTimer:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn PAL_FadeToBlack:proc

; GameInfoInit
; ============

    GameInfoInit:
    lda     #0
    sta     IRQCount
    sta     ScrollX
    sta     ScrollY
    jsr     ScreenOff
    jsr     ClearDisplay
    jsr     PAL_SetBlackPalette
; load game info screen
    lda     #<GameInfoData
    ldy     #>GameInfoData
    jsr     WriteROMPPUString
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
;
    lda     #3
    ldx     #mrGameInfoInit2
    jsr     SetTimer
    jmp     ScreenOn

    GameInfoInit2:
    lda     #16
    ldx     #mrGameInfoMain
    jsr     SetTimer
    jmp     PAL_FadeFromBlack

; GameInfoMain
; ============

    GameInfoMain:
    lda     Timer
    bne     +
    lda     #mrTitleInit
    sta     MainRoutine
    jmp     PAL_FadeToBlack
  + rts


.end
