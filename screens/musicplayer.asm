.include "game.h"
.include "common/nes.h"
.include "sound/rnme.h"
.include "common/fade.h"
.include "screens/musicplayer.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "screens/screendata.h"
.include "screens/statusscreen.h"
.include "common/mmc3.h"

.codeseg

.public MusicPlayerInit
.public MusicPlayerMain

; MusicPlayerInit
; ===============

.proc MusicPlayerInit
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     ScrollX
    sta     ScrollY
    sta     IRQCount
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
    lda     #1
    sta     RNME_LoadTune
    sta     $9D
    jsr     PrintSong
    inc     MainRoutine
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack
.endp

.proc MusicPlayerMain
    lda     JoyFirst
    and     #btnB
    bne     @@ExitMusicPlayer
    lda     JoyFirst
    and     #btnLEFT
    bne     @@PlayPrevSong
    lda     JoyFirst
    and     #(btnRIGHT|btnSELECT)
    bne     @@PlayNextSong
    rts
    @@ExitMusicPlayer:
    lda     #mrTitleInit
    sta     MainRoutine
    jmp     PAL_FadeToBlack
    @@PlayPrevSong:
    dec     $9D
    bne     +
    lda     #16
    sta     $9D
  + lda     $9D
    sta     RNME_LoadTune
    jmp     PrintSong
    @@PlayNextSong:
    inc     $9D
    lda     $9D
    cmp     #17
    bne     +
    lda     #1
    sta     $9D
  + sta     RNME_LoadTune
    jmp     PrintSong
.endp

.proc PrintSong
    lda     #$22
    ldy     #$0F
    ldx     $9D
    stx     AC0
    ldx     #0
    stx     AC1
    stx     AC2
    ldx     #2
    jmp     PrintValue
.endp

.end
