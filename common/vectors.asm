.include "common/irq.h"
.include "main.h"
.include "common/nmi.h"
.codeseg

.dw NMI,RESET,IRQ

.end
