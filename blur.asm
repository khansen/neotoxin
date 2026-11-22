.include "game.h"

.codeseg

.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn PAL_LoadPalette:proc
.extrn StatusScreenCHR:label
.extrn LoadCHR:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn EndPPUString:proc

BlurPal:
.db $0F,$0F,$0F,$02
.db $0F,$0F,$02,$12
.db $0F,$02,$12,$22
.db $0F,$12,$22,$30
.db $0F,$0F,$0F,$02
.db $0F,$0F,$0F,$02
.db $0F,$0F,$0F,$02
.db $0F,$0F,$0F,$02

BlurSine:
.db 0,3,6,9,12,16,19,22
.db 24,27,30,33,36,38,41,43
.db 45,47,49,51,53,55,56,58
.db 59,60,61,62,63,63,64,64
.db 64,64,64,63,63,62,61,60
.db 59,58,56,55,53,51,49,47
.db 45,43,41,38,36,33,30,27
.db 24,22,19,16,12,9,6,3
.db 0,-3,-6,-9,-12,-16,-19,-22
.db -24,-27,-30,-33,-36,-38,-41,-43
.db -45,-47,-49,-51,-53,-55,-56,-58
.db -59,-60,-61,-62,-63,-63,-64,-64
.db -64,-64,-64,-63,-63,-62,-61,-60
.db -59,-58,-56,-55,-53,-51,-49,-47
.db -45,-43,-41,-38,-36,-33,-30,-27
.db -24,-22,-19,-16,-12,-9,-6,-3

    UpdateBlurSpot:
    lda     SinePos
    and     #$7F
    tay
    lda     BlurSine,y
    clc
    adc     #112
    sta     ScreenX
    lda     SinePos
    clc
;        adc     #40
    lsr
    and     #$7F
    tay
    lda     BlurSine,y
    clc
    adc     #104
    sta     ScreenY
    inc     SinePos
    rts

    BlurInit:
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     ScrollX
    sta     ScrollY
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
    lda     #<BlurPal
    ldy     #>BlurPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
;
    lda     #0
    tay
  - sta     $500,y
    iny
    bpl     -
    inc     MainRoutine
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack

    BlurMain:
    jsr     UpdateBlurSpot
;    jsr     UpdateBlur
;    jmp     WriteBlur

    UpdateBlur:
    lda     ScreenY
    and     #$F0
    sta     Temp
    lda     ScreenX
    lsr
    lsr
    lsr
    lsr
    ora     Temp
    tay
    ldx     #3
  - lda     #240
    sta     $500,y
    sta     $501,y
    sta     $502,y
    tya
    clc
    adc     #$10
    tay
    dex
    bne     -

    ldy     #0  ; start column
    clc
  - lda     $500-1,y
    adc     $500+1,y
    sta     Temp
    lda     #0
    adc     #0
    sta     Temp+1
    lda     Temp
    adc     $500-16,y
    sta     Temp
    lda     Temp+1
    adc     #0
    sta     Temp+1
    lda     Temp
    adc     $500+16,y
    sta     Temp
    lda     Temp+1
    adc     #0
    sta     Temp+1
    lsr     Temp+1
    ror     Temp
    lsr     Temp+1
    ror     Temp
    lda     Temp
    beq     +
    sec
    sbc     #1
  + sta     $500,y
    iny
    bne     -
;    rts

    WriteBlur:
    ldx     PPUStrIndex
    lda     #$23
    sta     PPUString,x
    inx
    ldy     #$C0
    lda     FrameCount
    lsr
    bcc     +
    ldy     #$E0
  + tya
    sta     PPUString,x
    inx
    lda     #32
    sta     PPUString,x
    inx
    ldy     #0
    bcc     +
    ldy     #$80
  +
  - lda     $500,y
    rol
    rol
    rol
    and     #$03
    sta     Temp
    lda     $500+1,y
    lsr
    lsr
    lsr
    lsr
    and     #$0C
    ora     Temp
    sta     Temp
    lda     $500+16,y
    lsr
    lsr
    and     #$30
    ora     Temp
    sta     Temp
    lda     $500+17,y
    and     #$C0
    ora     Temp
    sta     PPUString,x
    inx
    iny
    iny
    tya
    and     #$0F
    bne     -
    tya
    clc
    adc     #$10
    tay
    and     #$7F
    bne     -
    jmp     EndPPUString

.end
