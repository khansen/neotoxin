.include "game.h"
.include "common/nes.h"
.include "sound/rnme.h"
.include "common/fade.h"
.include "screens/gameover.h"
.include "common/mmc3.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "game/savegame.h"
.include "screens/screendata.h"
.include "engine/warp.h"
.include "common/nmi.h"
.include "game/maincycle.h"
.include "common/joypad.h"
.include "engine/ngsl.h"

.codeseg

.public GameOverInit
.public GameOverMain

; GameOverInit
; ============

.proc GameOverInit
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
.endp

; GameOverMain
; ============

.proc GameOverMain
    lda     JoyFirst
    and     #(btnSTART+btnA)
    bne     @@GameOverChoose
    lda     JoyFirst
    and     #(btnSELECT+btnDOWN+btnUP)
    beq     @@GameOverShowCursor
    lda     MenuSelect
    eor     #$01    ; toggle choice
    sta     MenuSelect
    @@GameOverShowCursor:
    lda     MenuSelect
    asl
    asl
    asl
    asl
    adc     #94
    sta     SPR_PosY
    rts
    @@GameOverChoose:
    jsr     PAL_FadeToBlack
    lda     MenuSelect
    beq     @@GameOverContinue
    lda     #mrTitleInit
    sta     MainRoutine
    rts
    @@GameOverContinue:
    lda     #0
    sta     RNME_LastTune
    jsr     LoadSaveGame
    jmp     ExecWarp
.endp

.end
