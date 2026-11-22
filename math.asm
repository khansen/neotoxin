.include "math.h"
.codeseg

.public XSIGN
.public CMC

; XSIGN
; =====
; A = -A

.proc XSIGN
    eor     #$FF
    clc
    adc     #$01
    rts
.endp

; CMC
; ===
; Complement carry flag. Since the 6502 doesn't have this instruction
; built-in...
; In: CF
; Out: !CF

.proc CMC
    rol
    eor     #$01            ; toggle carry
    ror
    rts
.endp


.end
