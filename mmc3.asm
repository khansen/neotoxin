.include "game.h"
.include "mmc3.h"

.codeseg

.public SetBank
.public SwapBank
.public ResetBank

; SetBank
; =======
; Loads 16K ROM bank in A at $8000.

        ResetBank:
        lda     CurrentBank
        SetBank:
        sta     CurrentBank
        SwapBank:
        asl
        tay                     ; Y = 8K bank #
        ldx     #$06            ; command = swap 1st 8K bank
        stx     MMC3_CTRL_REG
        sty     MMC3_PAGE_REG
        inx                     ; command = swap 2nd 8K bank
        iny
        stx     MMC3_CTRL_REG
        sty     MMC3_PAGE_REG
        rts

.end
