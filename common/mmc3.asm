.include "game.h"
.include "common/mmc3.h"

.codeseg

.public SetBank
.public SwapBank
.public ResetBank
.public LoadCHR

; SetBank
; =======
; Loads 16K ROM bank in A at $8000.

.proc ResetBank
        lda     CurrentBank
.endp
.proc SetBank
        sta     CurrentBank
.endp
.proc SwapBank
        asl
        tay                     ; Y = 8K bank #
        ldx     #$06            ; command = swap 1st 8K bank
        stx     MMC3Ctrl
        stx     MMC3_CTRL_REG
        sty     MMC3_PAGE_REG
        inx                     ; command = swap 2nd 8K bank
        iny
        stx     MMC3Ctrl
        stx     MMC3_CTRL_REG
        sty     MMC3_PAGE_REG
        rts
.endp

; LoadCHR
; =======
; Sets the eight 1K CHR pages to use when drawing the screen.
; In: A = low data address.
;     Y = high data address.

.proc LoadCHR
    sta     pData
    sty     pData+1
    ldy     #$05
  - lda     [pData],y
    sta     SelectedCHR,y
    dey
    bpl     -
    rts
.endp

.end
