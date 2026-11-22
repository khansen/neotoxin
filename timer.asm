; Description:
; The eight countdown timers (Timer), decremented every TIMER_SPEED frames.

.include "game.h"
.include "timer.h"

.codeseg

.public UpdateTimers

; UpdateTimers
; ============
; Decrements Timer every (1/60)*TIMER_SPEED seconds (AKA every TIMER_SPEEDth
; frame), if it isn't already zero.

.proc UpdateTimers
    dec     TimerDelay
    bpl     ++
    lda     #TIMER_SPEED-1
    sta     TimerDelay
    ldx     #$07            ; 8 timers to update
  - lda     Timer,x
    beq     +               ; don't modify if already zero
    dec     Timer,x
  + dex                     ; next timer
    bpl     -
 ++ rts
.endp

.end
