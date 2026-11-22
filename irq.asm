.include "mmc3.h"
.include "irq.h"
.include "maincycle.h"

.codeseg

.public IRQ

;-----------------------------------[ IRQ ]-----------------------------------

.proc IRQ
    sei
    pha                     ; push A on stack
    txa
    pha                     ; push X on stack
    tya
    pha                     ; push Y on stack

    sta     MMC3_IRQ_DISABLE_REG
    jsr     GoIRQRoutine

    pla
    tay                     ; restore Y
    pla
    tax                     ; restore X
    pla                     ; restore A
    rti
.endp

.end
