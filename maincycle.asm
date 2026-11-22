.include "game.h"
.include "hsge.h"
.include "mmc3.h"
.include "nes.h"
.include "area2d.h"
.include "demomode.h"
.include "entername.h"
.include "gameinfo.h"
.include "gameover.h"
.include "levelup.h"
.include "maincycle.h"
.include "musicplayer.h"
.include "ngsl.h"
.include "palette.h"
.include "ppu.h"
.include "screendata.h"
.include "selectgame.h"
.include "statusmain.h"
.include "titlescreen.h"
.include "vste.h"
.include "warp.h"

.codeseg

.public GoRoutine
.public GoMainHandler
.public GoIRQRoutine

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

.proc GoRoutine
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
.endp

; GoIRQRoutine
; ============

.proc GoIRQRoutine
    lda     IRQRoutine
    jsr     GoRoutine

TC_SLOT IRQScreenOff
TC_SLOT IRQSwitchBGCHR
.endp

.proc IRQScreenOff
    lda     ZPCtrl1
    and     #%11100111      ; bg & sprite visibility = false
    sta     PPUCtrl1
    rts
.endp

.proc IRQSwitchBGCHR
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
    lda     MMC3Ctrl
    ora     #$80
    sta     MMC3_CTRL_REG
    rts
.endp

; GoMainHandler
; =============

.proc GoMainHandler
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
.endp

; ScriptInit
; ==========

.proc ScriptInit
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
.endp

.end
