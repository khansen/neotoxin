.include "game.h"
.include "common/nes.h"
.include "common/joypad.h"

.dataseg zeropage

JoyStat             .byte   ; buttons held
JoyFirst            .byte   ; buttons pressed this frame

.codeseg

.public JoyStat
.public JoyFirst
.public ReadJoypad0

; ReadJoypad0
; ===========
; Reads the status of all 8 buttons.
; Returns: JoyStat  = button status.
;          JoyFirst = only reports a button press the first time the
;                     button is pressed; not while it's being held down.

.proc ReadJoypad0
    lda     JoyStat
    pha                     ; save last frame's status
    ldy     #$01
    sty     JoyReg          ; reset strobe
    dey
    sty     JoyReg          ; clear strobe
    ldy     #$08            ; do all 8 buttons       
  - lda     JoyReg          ; load button status
    lsr                     ; transfer to carry flag
    rol     JoyStat         ; rotate all bits left, put CF in bit 0
    dey                     ; done 8 buttons?
    bne     -               ; if not, do another
    pla                     ; last frame's button status
    eor     JoyStat
    and     JoyStat
    sta     JoyFirst
    rts
.endp


.end
