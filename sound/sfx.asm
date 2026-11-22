; Description:
; Starts sound effects. This unit is in the fixed bank so it can be called
; from any bank; the music engine (bank 6) starts the effect on its next
; update.

.include "sound/rnme.h"
.include "sound/sfx.h"

.codeseg

.public PlaySFX
.public PlayNoiseSFX

; PlaySFX
; =======
; Starts a sound effect on the sound effect channel (square 2).
; In: A = SFX_* number
; Preserves A, X and Y.

.proc PlaySFX
    sta     SFX_Number+1
    rts
.endp

; PlayNoiseSFX
; ============
; Starts a sound effect on the noise channel.
; In: A = SFX_* number
; Preserves A, X and Y.

.proc PlayNoiseSFX
    sta     SFX_Number+3
    rts
.endp

.end
