.include "rnme.h"

.codeseg

.public RNME_SetFreq
.public RNME_DoSlideUp
.public RNME_DoSlideDown
.public RNME_DoSlideNote
.public RNME_DoVibrato
.public RNME_DoArpeggio

.extrn RNME_VibratoTable:label
.extrn RNME_FreqTabLo:label
.extrn RNME_FreqTabHi:label

;-------------------------[ Vibrato implementation ]--------------------------

    RNME_DoVibrato:
; check vibrato delay
    lda     CHN_VibDelay,x
    beq     RNME_VibDelayEnded
    dec     CHN_VibDelay,x
    rts

    RNME_VibDelayEnded:
; reset channel frequency
    lda     CHN_Note,x
    jsr     RNME_SetFreq

; get sine value
    lda     CHN_VibratoPos,x
    and     #$1F
    tay
    lda     RNME_VibratoTable,y
    sta     RNME_Temp1

; *** convert sine value to real delta freq, according to vibrato depth ***

    lda     #$00
    sta     RNME_Temp2
    sta     RNME_Temp3
    lda     CHN_EffParam,x
    and     #$0F                    ; VibratoSpeed in lower 4 bits
    tay
    clc
; this loop performs SineValue*VibratoDepth
  - lda     RNME_Temp2
    adc     RNME_Temp1
    sta     RNME_Temp2
    bcc     +
    inc     RNME_Temp3
    clc
  + dey
    bne     -

; this stores the result of (SineValue*VibratoDepth)/128 in RNME_Temp3
    asl     RNME_Temp2
    rol     RNME_Temp3

    lda     CHN_VibratoPos,x
    bpl     RNME_VibAdd

; VibratoPos negative --> SUBTRACT delta
    lda     CHN_Reg2,x
    sec
    sbc     RNME_Temp3
    sta     CHN_Reg2,x
    bcs     RNME_VibDone
    dec     CHN_FreqHi,x
    bcc     RNME_VibDone

; VibratoPos positive --> ADD delta
    RNME_VibAdd:
    lda     CHN_Reg2,x
    clc
    adc     RNME_Temp3
    sta     CHN_Reg2,x
    bcc     RNME_VibDone
    inc     CHN_FreqHi,x

    RNME_VibDone:
    lda     CHN_EffParam,x
    lsr
    lsr
    lsr
    lsr
    clc
    adc     CHN_VibratoPos,x        ; add VibratoSpeed to VibratoPos
    cmp     #$20                    ; wraps at 32
    bcc     +
    cmp     #$30
    bcs     +
    sbc     #$40
  + sta     CHN_VibratoPos,x
    rts

;----------------------[ Slide to note implementation ]-----------------------

    RNME_DoSlideNote:
    lda     CHN_EffInfo,x
    bpl     RNME_SlideExit
    lsr
    bcc     RNME_SlideDown

    jsr     RNME_DoSlideUp
; check if slide frequency has been reached
    lda     CHN_Reg2,x
    cmp     CHN_SlFreqLo,x
    lda     CHN_FreqHi,x
    sbc     CHN_SlFreqHi,x
    bpl     RNME_SlideExit

    RNME_SlideDone:
    lda     CHN_SlFreqLo,x
    sta     CHN_Reg2,x
    lda     CHN_SlFreqHi,x
    sta     CHN_FreqHi,x
    lda     #$00
    sta     CHN_EffInfo,x
    rts

    RNME_SlideDown:
    jsr     RNME_DoSlideDown
; check if slide frequency has been reached
    lda     CHN_Reg2,x
    cmp     CHN_SlFreqLo,x
    lda     CHN_FreqHi,x
    sbc     CHN_SlFreqHi,x
    bpl     RNME_SlideDone

    RNME_SlideExit:
    rts

;-----------------------[ Slide down implementation ]-------------------------

    RNME_DoSlideDown:
; slide down by adding slide amount to channel frequency
    lda     CHN_Reg2,x
    clc
    adc     CHN_EffParam,x
    sta     CHN_Reg2,x
    bcc     +
    inc     CHN_FreqHi,x
  + rts

;------------------------[ Slide up implementation ]--------------------------

    RNME_DoSlideUp:
; slide up by subtracting slide amount from channel frequency
    lda     CHN_Reg2,x
    sec
    sbc     CHN_EffParam,x
    sta     CHN_Reg2,x
    bcs     +
    dec     CHN_FreqHi,x
  + rts

;------------------------[ Arpeggio implementation ]--------------------------

    RNME_DoArpeggio:
;        lda     CHN_ArpSpeed,x
;        lsr
    lda     CHN_Tick,x
;        bcc     +
    lsr
    sec
  - cmp     #$03
    bcc     +
    sbc     #$03
    bpl     -

    ; A = Tick % 3
  + cmp     #$01
    beq     RNME_AddNote1
    bcs     RNME_AddNote2
    lda     CHN_Note,x
    bpl     RNME_SetFreq

    RNME_AddNote1:
    lda     CHN_EffParam,x
    lsr
    lsr
    lsr
    lsr
    clc
    adc     CHN_Note,x
    bpl     RNME_SetFreq

    RNME_AddNote2:
    lda     CHN_EffParam,x
    and     #$0F
    clc
    adc     CHN_Note,x

    RNME_SetFreq:
    tay
    lda     RNME_FreqTabLo,y
    sta     CHN_Reg2,x
    lda     RNME_FreqTabHi,y
    sta     CHN_FreqHi,x
    rts

.end
