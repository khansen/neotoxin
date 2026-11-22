.include "game.h"
.include "area2d.h"
.include "fade.h"
.include "gameinfo.h"
.include "palette.h"
.include "ppu.h"
.include "screendata.h"

.codeseg

.public GameInfoInit
.public GameInfoInit2
.public GameInfoMain

; GameInfoInit
; ============

.proc GameInfoInit
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
.endp

.proc GameInfoInit2
    lda     #16
    ldx     #mrGameInfoMain
    jsr     SetTimer
    jmp     PAL_FadeFromBlack
.endp

; GameInfoMain
; ============

.proc GameInfoMain
    lda     Timer
    bne     +
    lda     #mrTitleInit
    sta     MainRoutine
    jmp     PAL_FadeToBlack
  + rts
.endp

.end
