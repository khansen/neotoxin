.include "game.h"

.codeseg

.public ClearRAM
.public ClearWRAM

; ClearRAM
; ========
; Clears RAM at $0000-$07FF

    ClearRAM:
    lda     #$00
    tax
  - sta     $00,x
    sta     $0200,x
    sta     $0300,x
    sta     $0400,x
    sta     $0500,x
    sta     $0600,x
    sta     $0700,x
    inx
    bne     -
    rts

; ClearWRAM
; =========
; Clears WRAM at $6000-$7FFF

    ClearWRAM:
    lda     #$7F            ; high byte of last WRAM page
    sta     pData+1
    lda     #$00            ; low byte of last WRAM page
    sta     pData
    tay
  - sta     [pData],y     ; clear address
    iny                     ; cleared 256 bytes?
    bne     -               ; if not, clear another
    dec     pData+1       ; decrement high byte of address
    ldx     pData+1
;        cpx     #$60
    cpx     #$70
    bcs     -               ; clear another page if >= $60
    rts


.end
