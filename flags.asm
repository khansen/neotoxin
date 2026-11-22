.include "game.h"

.codeseg

.public SetStatusFlag
.public ResetStatusFlag
.public GetStatusFlag

.extrn BitMaskTable:label

; GetStatusFlag
; =============
; in: A = flag #
; out: ZF=0 if flag set, else ZF=1

    GetStatusFlag:
    pha
    lsr
    lsr
    lsr
    tay
    lda     StatusFlags,y
    sta     Temp
    pla
    and     #$07
    tay
    lda     Temp
    and     BitMaskTable,y
    rts

; SetStatusFlag
; =============
; in: A = flag #

    SetStatusFlag:
    pha
    and     #$07
    tay
    lda     BitMaskTable,y
    sta     Temp
    pla
    lsr
    lsr
    lsr
    tay
    lda     StatusFlags,y
    ora     Temp
    sta     StatusFlags,y
    rts

; ResetStatusFlag
; ===============
; in: A = flag #

    ResetStatusFlag:
    pha
    and     #$07
    tay
    lda     BitMaskTable,y
    eor     #$FF
    sta     Temp
    pla
    lsr
    lsr
    lsr
    tay
    lda     StatusFlags,y
    and     Temp
    sta     StatusFlags,y
    rts


.end
