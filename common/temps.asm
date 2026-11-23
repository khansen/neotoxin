; Description:
; The eight countdown timers (Timer), decremented every TIMER_SPEED frames.

; Description:
; The shared zero page temporaries declared in common/temps.h.

.include "common/temps.h"

.public pCode, pData, Temp, Count, Count2, Count3, Index, Index2, Index3, Index4

.dataseg zeropage

pCode           .word
pData           .word
Temp            .byte[4]
Count           .byte
Count2          .byte
Count3          .byte
Index           .byte
Index2          .byte
Index3          .byte
Index4          .byte

.end
