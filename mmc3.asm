.include "game.h"
.include "mmc3.h"

.codeseg

.public SetBank
.public SwapBank
.public ResetBank

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

.end
