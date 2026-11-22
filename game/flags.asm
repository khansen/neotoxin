.include "game.h"
.include "game/flags.h"
.include "game/gamedata.h"

.codeseg

.public SetStatusFlag
.public ResetStatusFlag
.public GetStatusFlag

; GetStatusFlag
; =============
; in: A = flag #
; out: ZF=0 if flag set, else ZF=1

.proc GetStatusFlag
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
.endp

; SetStatusFlag
; =============
; in: A = flag #

.proc SetStatusFlag
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
.endp

; ResetStatusFlag
; ===============
; in: A = flag #

.proc ResetStatusFlag
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
.endp

.end
