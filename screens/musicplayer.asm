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
.include "common/nmi.h"
.include "game/maincycle.h"
.include "common/joypad.h"

SONG_COUNT      EQU     16      ; songs are numbered 1..SONG_COUNT

.dataseg

SongNumber      .byte           ; the song being played

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
    sta     SongNumber
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
    dec     SongNumber
    bne     +
    lda     #SONG_COUNT
    sta     SongNumber
  + lda     SongNumber
    sta     RNME_LoadTune
    jmp     PrintSong
    @@PlayNextSong:
    inc     SongNumber
    lda     SongNumber
    cmp     #SONG_COUNT+1
    bne     +
    lda     #1
    sta     SongNumber
  + sta     RNME_LoadTune
    jmp     PrintSong
.endp

.proc PrintSong
    lda     #$22
    ldy     #$0F
    ldx     SongNumber
    stx     AC0
    ldx     #0
    stx     AC1
    stx     AC2
    ldx     #2
    jmp     PrintValue
.endp

.end
