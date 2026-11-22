.include "game.h"
.include "mmc3.h"
.include "nes.h"
.include "obj.h"
.include "rnme.h"
.include "entername.h"
.include "fade.h"
.include "gamedata.h"
.include "palette.h"
.include "ppu.h"
.include "screendata.h"
.include "titlescreen.h"

DEMO_FRAMECOUNT_SEED    EQU     $34

.codeseg

.public TitleInit
.public TitleMain

.proc TitleInit
    jsr     ScreenOff
    lda     ZPCtrl0
    and     #$FC            ; nametable address = $2000
    sta     ZPCtrl0
    lda     #0
    sta     ScrollX
    sta     ScrollY
    lda     #1
    sta     IRQRoutine
    lda     #119
    sta     IRQCount
    lda     #H_MIRROR
    sta     MMC3_MIRROR_REG
    lda     #$08
    sta     MaxSpeed
    lda     #$40
    sta     Timer
    jsr     ClearDisplay
    lda     #<TitleData
    ldy     #>TitleData
    jsr     WriteROMPPUString
    lda     #<TitleCHR
    ldy     #>TitleCHR
    jsr     LoadCHR
; set up sprite 0
    lda     #174
    sta     SPR_PosY
    lda     #$A3
    sta     SPR_Tile
    lda     #32
    sta     SPR_PosX
    lda     #0
    sta     SPR_Attrib
    lda     #5      ; title music
    sta     RNME_LoadTune
    lda     #<TitlePal
    ldy     #>TitlePal
    jsr     PAL_LoadPalette
    jsr     ScreenOn
    inc     MainRoutine
    jmp     PAL_FadeFromBlack
.endp

;-------------------------[ Title screen main loop ]--------------------------

.proc TitleMain
; check for button presses
    lda     JoyFirst
    and     #btnSELECT
    beq     +
; enter music player
    lda     #mrMusicPlayerInit
    sta     MainRoutine
    jmp     PAL_FadeToBlack
;
  + lda     JoyFirst
    and     #(btnSTART+btnA)
    bne     @@TitleStartPressed
; see if it's time to start game demo
    lda     Timer
    bne     +
    jsr     PAL_FadeToBlack
    lda     DemoNumber
    asl
    tax
    lda     GameDemos,x
    sta     pDemo
    lda     GameDemos+1,x
    sta     pDemo+1
    lda     #$01
    sta     JoyCount
    sta     DemoMode
; seed the RNG inputs so every demo run plays out identically
    lda     #DEMO_FRAMECOUNT_SEED
    sta     FrameCount
    jsr     InitGameState
    sta     Random
    sta     CurrentArea
    sta     OBJ_State
    lda     #mrExecWarp
    sta     MainRoutine
    rts
; wait for sprite 0 hit
  +
  - lda     PPUStat
    asl
    bmi     -
  - lda     PPUStat
    asl
    bpl     -
; do wave effect
    lda     SinePos
    and     #$1F
    tax
    ldy     #40      ; # of scanlines to apply the wave on
    @@TitleWaveLoop:
    lda     PPUStat  ; 4
    lda     TitleSine,x  ; 4
    sta     PPUScroll ; 4
    tya             ; 2
    ldy     #16     ; 2             = 4 total
  - dey             ; 2 *
    bne     -       ; 3 *           = 80-1 total
    tay             ; 2
    inx             ; 2
    txa             ; 2
    and     #$1F    ; 2
    tax             ; 2
    nop             ; 2
    nop             ; 2
    dey             ; 2
    bne     @@TitleWaveLoop ; 3             = 31 total
    ; 4 + 79 + 31 = 114
    sty     PPUScroll
    sty     PPUScroll
    inc     SinePos
    rts

    @@TitleStartPressed:
    jsr     PAL_FadeToWhite
    jsr     PAL_FadeFromWhite
    jsr     PAL_FadeToBlack
    lda     #0
    sta     IRQCount
    sta     DemoMode
    lda     #mrSelectGameInit
    sta     MainRoutine
    rts
.endp

.end
