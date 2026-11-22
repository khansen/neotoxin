.include "game.h"
.include "fade.h"
.include "ppu.h"

.codeseg

.public PAL_FadeFromBlack
.public PAL_FadeToBlack
.public PAL_FadeToWhite
.public PAL_FadeFromWhite
.public PAL_StrSetup

; PAL_FadeFromBlack
; =================
; Fades in the currently loaded palette.

.proc PAL_FadeFromBlack
        jsr     PAL_StrSetup
        ldx     #$1F
      - lda     RAMPalette,x
        and     #$0F            ; color intensity = 0
        sta     PPUString+3,x
        dex
        bpl     -

        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromBlackStep
        jmp     WaitNMIPass
.endp

.proc PAL_FadeFromBlackStep
        ldx     #$1F
      - lda     PPUString+3,x
        cmp     RAMPalette,x    ; has color reached full intensity?
        bcs     +               ; if yes, don't modify it
        adc     #$10            ; increase color intensity by 1
        sta     PPUString+3,x
      + dex
        bpl     -
        rts
.endp

;-----------------------------------------------------------------------------

; PAL_FadeFromWhite
; =================
; Fades in the currently loaded palette.

.proc PAL_FadeFromWhite
        jsr     PAL_StrSetup
        ldx     #$1F
      - lda     RAMPalette,x
        ora     #$30            ; color intensity = full
        cmp     #$3F
        bne     +
        lda     #$30
      + sta     PPUString+3,x
        dex
        bpl     -

        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeFromWhiteStep
        jmp     PAL_FadeDelay
.endp

.proc PAL_FadeFromWhiteStep
        ldx     #$1F
      - lda     PPUString+3,x
        cmp     RAMPalette,x    ; has color reached full intensity?
        beq     ++              ; if yes, don't modify it
        cmp     #$00
        bne     +
        lda     #$0F
        bne     ++
      + sec
        sbc     #$10            ; decrease color intensity by 1
     ++ sta     PPUString+3,x
        dex
        bpl     -
        rts
.endp

;-----------------------------------------------------------------------------

; PAL_FadeToBlack
; ===============
; Fades the currently loaded palette to all black.

.proc PAL_FadeToBlack
        jsr     PAL_StrSetup
        ldx     #$1F
      - lda     RAMPalette,x
        sta     PPUString+3,x
        dex
        bpl     -

        jsr     PAL_FadeToBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToBlackStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToBlackStep
        jmp     PAL_FadeDelay
.endp

.proc PAL_FadeToBlackStep
        ldx     #$1F
      - lda     PPUString+3,x
        sec
        sbc     #$10            ; decrease color intensity by 1
        bcs     +               ; if result is < 0...
        lda     #$0F            ; ... color = black
      + sta     PPUString+3,x
        dex
        bpl     -
        rts
.endp

;-----------------------------------------------------------------------------

; PAL_FadeToWhite
; ===============
; Fades the currently loaded palette to all white.

.proc PAL_FadeToWhite
        jsr     PAL_StrSetup
        ldx     #$1F
      - lda     RAMPalette,x
        cmp     #$0F
        bne     +
        lda     #$F0
      + sta     PPUString+3,x
        dex
        bpl     -

        jsr     PAL_FadeToWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToWhiteStep
        jsr     PAL_FadeDelay
        jsr     PAL_FadeToWhiteStep
        jmp     PAL_FadeDelay
.endp

.proc PAL_FadeToWhiteStep
        ldx     #$1F
      - lda     PPUString+3,x
        clc
        adc     #$10            ; increase color intensity by 1
        cmp     #$40
        bcc     +               ; if result is >= 64...
        lda     #$30            ; ... color = white
      + sta     PPUString+3,x
        dex
        bpl     -
        rts
.endp

;-----------------------------------------------------------------------------

.proc PAL_StrSetup
        lda     #$20
        sta     PPUString+2
        lda     #$3F
        sta     PPUString
        lda     #$00
        sta     PPUString+1
        sta     PPUString+35
        rts
.endp

.proc PAL_FadeDelay
        lda     #$01
        sta     PPUDataPending
        ldy     #$06
        jmp     FrameDelay
.endp

.end
