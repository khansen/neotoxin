.include "game.h"
.include "hsge.h"
.include "mmc3.h"
.include "nes.h"

.codeseg

.public GoRoutine
.public GoMainHandler
.public GoIRQRoutine

.extrn TitleInit:proc
.extrn TitleMain:proc
.extrn ExecWarp:proc
.extrn Area2DInit:proc
.extrn Area2DMain:proc
.extrn PlayDemo:proc
.extrn StatusMain:proc
.extrn LevelUpInit:proc
.extrn LevelUpMain:proc
.extrn GameOverInit:proc
.extrn GameOverMain:proc
.extrn EnterNameInit:proc
.extrn EnterNameMain:proc
.extrn SelectGameInit:proc
.extrn SelectGameMain:proc
.extrn GameMenuMain:proc
.extrn StartNewGame:proc
.extrn PerformNameChange:proc
.extrn CreditsInit:proc
.extrn CreditsMain:proc
.extrn GameInfoInit:proc
.extrn GameInfoInit2:proc
.extrn GameInfoMain:proc
.extrn WaitTimer:proc
.extrn NGSL_ExecScript:proc
.extrn MusicPlayerInit:proc
.extrn MusicPlayerMain:proc
.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn SetBank:proc
.extrn DialogScreenData:label
.extrn WriteROMPPUString:proc
.extrn StatusScreenPal:label
.extrn PAL_LoadPalette:proc
.extrn StatusScreenCHR:label
.extrn LoadCHR:proc

.macro TC_SLOT addr
    .db >(addr-1), <(addr-1)
.endm

; GoRoutine
; =========
; Indirect jump routine.
; A: Routine # to execute
; A is used as an index into a table of code addresses.
; The jump table itself MUST be located directly after the JSR to this
; routine, so that its address can be popped from the stack.

    GoRoutine:
    asl                     ; each ptr is 2 bytes
    tay
    iny                     ; b/c stack holds jump table address MINUS 1
    pla                     ; low address of jump table
    sta     pCode
    pla                     ; high address of jump table
    sta     pCode+1
    lda     [pCode],y
    pha
    iny
    lda     [pCode],y
    pha
    rts                     ; jump to routine

; GoIRQRoutine
; ============

    GoIRQRoutine:
    lda     IRQRoutine
    jsr     GoRoutine

TC_SLOT IRQScreenOff
TC_SLOT IRQSwitchBGCHR

    IRQScreenOff:
    lda     ZPCtrl1
    and     #%11100111      ; bg & sprite visibility = false
    sta     PPUCtrl1
    rts

    IRQSwitchBGCHR:
    ldx     #$82
    ldy     #0
    stx     MMC3_CTRL_REG
    sty     MMC3_PAGE_REG
    inx
    iny
    stx     MMC3_CTRL_REG
    sty     MMC3_PAGE_REG
    inx
    iny
    stx     MMC3_CTRL_REG
    sty     MMC3_PAGE_REG
    inx
    iny
    stx     MMC3_CTRL_REG
    sty     MMC3_PAGE_REG
    rts

; GoMainHandler
; =============

    GoMainHandler:
    lda     MainRoutine
    jsr     GoRoutine

TC_SLOT TitleInit
TC_SLOT TitleMain
TC_SLOT ExecWarp
TC_SLOT Area2DInit
TC_SLOT Area2DMain
TC_SLOT PlayDemo
TC_SLOT StatusMain
TC_SLOT LevelUpInit
TC_SLOT LevelUpMain
TC_SLOT GameOverInit
TC_SLOT GameOverMain
TC_SLOT EnterNameInit
TC_SLOT EnterNameMain
;TC_SLOT BlurInit
;TC_SLOT BlurMain
TC_SLOT SelectGameInit
TC_SLOT SelectGameMain
TC_SLOT GameMenuMain
TC_SLOT StartNewGame
TC_SLOT PerformNameChange
TC_SLOT CreditsInit
TC_SLOT CreditsMain
TC_SLOT GameInfoInit
TC_SLOT GameInfoInit2
TC_SLOT GameInfoMain
TC_SLOT WaitTimer
TC_SLOT ScriptInit
TC_SLOT NGSL_ExecScript
TC_SLOT MusicPlayerInit
TC_SLOT MusicPlayerMain

; ScriptInit
; ==========

    ScriptInit:
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     ScrollX
    sta     ScrollY
    sta     IRQCount
    jsr     SetBank
    lda     ZPCtrl0
    sta     HSGE_Temp2000   ; preserve screen settings
    lda     ZPCtrl0
    and     #$FC
    sta     ZPCtrl0
    lda     #<DialogScreenData
    ldy     #>DialogScreenData
    jsr     WriteROMPPUString
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
    inc     MainRoutine     ; mrExecScript
    rts


.end
