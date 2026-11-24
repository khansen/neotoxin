.include "game.h"
.include "engine/hsge.h"
.include "common/mmc3.h"
.include "common/nes.h"
.include "engine/area2d.h"
.include "game/demomode.h"
.include "screens/entername.h"
.include "screens/gameinfo.h"
.include "screens/gameover.h"
.include "game/levelup.h"
.include "game/maincycle.h"
.include "screens/musicplayer.h"
.include "engine/ngsl.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "screens/screendata.h"
.include "screens/selectgame.h"
.include "screens/titlescreen.h"
.include "engine/vste.h"
.include "engine/warp.h"
.include "screens/statusscreen.h"
.include "common/nmi.h"

.dataseg zeropage

MainRoutine         .byte   ; mr* routine run every frame
NextRoutine         .byte
IRQRoutine          .byte   ; GoIRQRoutine entry

.codeseg

.public MainRoutine
.public NextRoutine
.public IRQRoutine
.public GoRoutine
.public GoMainHandler
.public GoIRQRoutine

.macro TC_SLOT addr
    .db >(addr-1), <(addr-1)
.endm

; One GoMainHandler table entry. Each entry names the mr* constant (game.h)
; that selects it; assembly fails if an entry is out of mr* order.
mr_slot = 0
.macro MAIN_SLOT id, addr
.if id != mr_slot
.error "GoMainHandler table entry out of mr* order"
.endif
mr_slot = mr_slot + 1
    TC_SLOT addr
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
; Runs the routine IRQRoutine selects. The IRQ interrupts the main code
; anywhere, so this must not use GoRoutine (which keeps the table address in
; pCode) or any other shared temporary.

.proc GoIRQRoutine
    lda     IRQRoutine
    asl
    tay
    lda     @@Table,y
    pha
    lda     @@Table+1,y
    pha
    rts                     ; jump to routine

    @@Table:
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

MAIN_SLOT mrTitleInit, TitleInit
MAIN_SLOT mrTitleMain, TitleMain
MAIN_SLOT mrExecWarp, ExecWarp
MAIN_SLOT mrArea2DInit, Area2DInit
MAIN_SLOT mrArea2DMain, Area2DMain
MAIN_SLOT mrPlayDemo, PlayDemo
MAIN_SLOT mrStatusMain, StatusMain
MAIN_SLOT mrLevelUpInit, LevelUpInit
MAIN_SLOT mrLevelUpMain, LevelUpMain
MAIN_SLOT mrGameOverInit, GameOverInit
MAIN_SLOT mrGameOverMain, GameOverMain
MAIN_SLOT mrEnterNameInit, EnterNameInit
MAIN_SLOT mrEnterNameMain, EnterNameMain
MAIN_SLOT mrSelectGameInit, SelectGameInit
MAIN_SLOT mrSelectGameMain, SelectGameMain
MAIN_SLOT mrGameMenuMain, GameMenuMain
MAIN_SLOT mrStartNewGame, StartNewGame
MAIN_SLOT mrPerformNameChange, PerformNameChange
MAIN_SLOT mrCreditsInit, CreditsInit
MAIN_SLOT mrCreditsMain, CreditsMain
MAIN_SLOT mrGameInfoInit, GameInfoInit
MAIN_SLOT mrGameInfoInit2, GameInfoInit2
MAIN_SLOT mrGameInfoMain, GameInfoMain
MAIN_SLOT mrWaitTimer, WaitTimer
MAIN_SLOT mrScriptInit, ScriptInit
MAIN_SLOT mrScriptMain, NGSL_ExecScript
MAIN_SLOT mrMusicPlayerInit, MusicPlayerInit
MAIN_SLOT mrMusicPlayerMain, MusicPlayerMain
.if mr_slot != MR_COUNT
.error "GoMainHandler table does not cover every mr* routine"
.endif
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
