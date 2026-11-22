.include "irq.h"
.include "main.h"
.include "nmi.h"
.codeseg

.dw NMI,RESET,IRQ

.end
