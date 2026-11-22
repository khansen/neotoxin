.include "game.h"
.include "nes.h"
.include "rnme.h"

.codeseg

.public GameOverInit
.public GameOverMain

.extrn PAL_FadeToBlack:proc
.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn SetBank:proc
.extrn GameOverData:label
.extrn WriteROMPPUString:proc
.extrn GameOverPal:label
.extrn PAL_LoadPalette:proc
.extrn GameOverCHR:label
.extrn LoadCHR:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn LoadSaveGame:proc
.extrn ExecWarp:proc

; GameOverInit
; ============

    GameOverInit:
    jsr     PAL_FadeToBlack
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     IRQCount
    sta     ScrollX
    sta     ScrollY
    sta     MenuSelect
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
    lda     #0
    jsr     SetBank
; load game over screen
    lda     #<GameOverData
    ldy     #>GameOverData
    jsr     WriteROMPPUString
    lda     #<GameOverPal
    ldy     #>GameOverPal
    jsr     PAL_LoadPalette
    lda     #<GameOverCHR
    ldy     #>GameOverCHR
    jsr     LoadCHR
; set up sprite 0
    lda     #$0B    ; round dot
    sta     SPR_Tile
    lda     #86
    sta     SPR_PosX
    lda     #0
    sta     SPR_Attrib
; start "game over" music
;
    inc     MainRoutine
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack

; GameOverMain
; ============

    GameOverMain:
    lda     JoyFirst
    and     #(btnSTART+btnA)
    bne     GameOverChoose
    lda     JoyFirst
    and     #(btnSELECT+btnDOWN+btnUP)
    beq     GameOverShowCursor
    lda     MenuSelect
    eor     #$01    ; toggle choice
    sta     MenuSelect
    GameOverShowCursor:
    lda     MenuSelect
    asl
    asl
    asl
    asl
    adc     #94
    sta     SPR_PosY
    rts
    GameOverChoose:
    jsr     PAL_FadeToBlack
    lda     MenuSelect
    beq     GameOverContinue
    lda     #mrTitleInit
    sta     MainRoutine
    rts
    GameOverContinue:
    lda     #0
    sta     RNME_LastTune
    jsr     LoadSaveGame
    jmp     ExecWarp


.end
