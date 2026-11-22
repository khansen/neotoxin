.ifndef MMC3_H
.define MMC3_H

V_MIRROR                EQU     0
H_MIRROR                EQU     1

MMC3_CTRL_REG           EQU     $8000
MMC3_PAGE_REG           EQU     $8001
MMC3_MIRROR_REG         EQU     $A000
MMC3_WRAM_REG           EQU     $A001
MMC3_IRQ_COUNTER_REG    EQU     $C000
MMC3_IRQ_LATCH_REG      EQU     $C001
MMC3_IRQ_DISABLE_REG    EQU     $E000
MMC3_IRQ_ENABLE_REG     EQU     $E001

.endif
