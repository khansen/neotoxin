.include "game.h"
.include "mmc3.h"
.include "nes.h"
.include "rnme.h"

.codeseg

.public TitleInit
.public TitleMain

.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn TitleData:label
.extrn WriteROMPPUString:proc
.extrn TitleCHR:label
.extrn LoadCHR:proc
.extrn TitlePal:label
.extrn PAL_LoadPalette:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn PAL_FadeToBlack:proc
.extrn GameDemos:label
.extrn TitleSine:label
.extrn PAL_FadeToWhite:proc
.extrn PAL_FadeFromWhite:proc

    TitleInit:
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

;-------------------------[ Title screen main loop ]--------------------------

    TitleMain:
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
    bne     TitleStartPressed
; see if it's time to start game demo
    lda     Timer
    bne     +
; yep
    beq     +   ; nope
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
; TODO: load savegame...
    lda     #mrExecWarp
    sta     MainRoutine
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
    TitleWaveLoop:
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
    bne     TitleWaveLoop ; 3             = 31 total
    ; 4 + 79 + 31 = 114
    sty     PPUScroll
    sty     PPUScroll
    inc     SinePos
    rts

    TitleStartPressed:
    jsr     PAL_FadeToWhite
    jsr     PAL_FadeFromWhite
    jsr     PAL_FadeToBlack
    lda     #0
    sta     IRQCount
    sta     DemoMode
    lda     #mrSelectGameInit
    sta     MainRoutine
    rts

.end
