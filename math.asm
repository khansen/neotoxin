.codeseg

.public XSIGN
.public CMC

; XSIGN
; =====
; A = -A

    XSIGN:
    eor     #$FF
    clc
    adc     #$01
    rts

; CMC
; ===
; Complement carry flag. Since the 6502 doesn't have this instruction
; built-in...
; In: CF
; Out: !CF

    CMC:
    rol
    eor     #$01            ; toggle carry
    ror
    rts


.end
