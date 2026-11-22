.codeseg

.public XSIGN
.public CMC

; ABS
; ===
; A = abs(A)

; XSIGN
; =====
; A = -A

    ABS:
    cmp     #$80
    bcc     +
    XSIGN:
    eor     #$FF
    clc
    adc     #$01
  + rts

; BitScan
; =======
; Searches A for the least significant set bit, and returns its index in Y.
; If no set bits are found, Y=8 on return.

    BitScan:
    ldy     #0              ; first bit to test is bit 0
  - lsr                     ; transfer bit to carry flag
    bcs     +               ; if it's set, we're done
    iny                     ; else try the next bit
    cpy     #8
    bne     -
  + rts

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
