.include "rnme.h"

.codeseg

.public ENV_Update

.extrn CMC:proc

;--------------------[ Volume envelope implementation ]-----------------------

; ENV_Init
; ========

    ENV_Init:
    lsr     ENV_Phase,x             ; phase = update envelope
    lda     #0
    sta     ENV_Index,x             ; reset envelope position
    lda     ENV_pLopeLo,x
    sta     RNME_pEnvelope
    lda     ENV_pLopeHi,x
    sta     RNME_pEnvelope+1         ; set pointer to envelope
    ENV_InitVol:
    jsr     ENV_GetByte
    sta     ENV_CurrentVol,x        ; 1st byte = start volume

    ENV_PointInit:
    jsr     ENV_GetByte
    cmp     #$FF                    ; $FF = end of envelope reached
    beq     ENV_EndOfLope

    sta     ENV_StepHi,x
    jsr     ENV_GetByte
    sta     ENV_StepLo,x
    jsr     ENV_GetByte
    sta     ENV_HoldLength,x
    jsr     ENV_GetByte
    sta     ENV_DestVol,x

    lda     #$00
    sta     ENV_Fraction,x
    rts

    ENV_EndOfLope:
    jsr     ENV_GetByte
    cmp     #$FF
    beq     ENV_StopLope
    sta     ENV_Index,x     ; loop the envelope
    jmp     ENV_InitVol

    ENV_StopLope:
    lda     #$00
    sta     ENV_Phase,x
    rts

; ENV_Update
; ==========

    ENV_Update:
    lda     ENV_Phase,x
    bmi     ENV_Init                ; phase = $80
    asl
    bmi     ENV_Process             ; phase = $40
    asl
    bmi     ENV_Sustain             ; phase = $20
  - rts

; ENV_Process
; ===========

    ENV_Process:
    lda     ENV_Fraction,x
    clc
    adc     ENV_StepLo,x
    sta     ENV_Fraction,x
    php

    lda     ENV_CurrentVol,x
    cmp     ENV_DestVol,x
    bcs     ENV_SubVolume

; CurrentVol < DestVol ==> CurrentVol += StepHi
    plp
    adc     ENV_StepHi,x
    cmp     ENV_DestVol,x
    bcs     ENV_ReachedDest
    sta     ENV_CurrentVol,x
    rts

; CurrentVol > DestVol ==> CurrentVol -= StepHi
    ENV_SubVolume:
    plp
    jsr     CMC
    sbc     ENV_StepHi,x
    bmi     ENV_ReachedDest
    cmp     ENV_DestVol,x
    beq     ENV_ReachedDest+3
    bcc     ENV_ReachedDest
    sta     ENV_CurrentVol,x
    rts

    ENV_ReachedDest:
    lda     ENV_DestVol,x
    sta     ENV_CurrentVol,x
    lda     ENV_HoldLength,x
    beq     ENV_NextPoint

    lsr     ENV_Phase,x             ; phase = sustain
    rts

    ENV_NextPoint:
    lda     ENV_pLopeLo,x
    sta     RNME_pEnvelope
    lda     ENV_pLopeHi,x
    sta     RNME_pEnvelope+1
    jmp     ENV_PointInit

; ENV_Sustain
; ===========

    ENV_Sustain:
    ldy     ENV_HoldLength,x
    iny
    beq     -                       ; sustain forever if length = $FF
    dec     ENV_HoldLength,x
    bne     -
    asl     ENV_Phase,x             ; phase = process
    jmp     ENV_NextPoint

;
; ENV_GetByte
;

    ENV_GetByte:
    ldy     ENV_Index,x
    inc     ENV_Index,x
    lda     [RNME_pEnvelope],y
    rts

.end
