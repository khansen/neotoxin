.include "game.h"
.include "common/mmc3.h"
.include "common/nes.h"
.include "common/clearram.h"
.include "main.h"
.include "game/maincycle.h"
.include "common/ppu.h"
.include "common/timer.h"
.include "common/nmi.h"

.codeseg

.public RESET

;--------------------------[ Program entrypoint ]-----------------------------

.proc RESET
    cld                     ; clear decimal mode
    ldx     #$00
    stx     PPUCtrl0        ; disable NMI and stuff
    stx     PPUCtrl1        ; disable BG & SPR visibility and stuff
    stx     MMC3_IRQ_DISABLE_REG
    dex                     ; X = FF
    txs                     ; S points to end of stack page (1FF)

  - lda     PPUStat
    bpl     -
  - lda     PPUStat
    bpl     -

    lda     #$80
    sta     MMC3_WRAM_REG           ; enable WRAM
    lda     #$40
    sta     $4017           ; disable erratic IRQ triggering
    cli                     ; enable interrupts

    jsr     ClearRAM
    jsr     ClearWRAM

    lda     #%00000000      ; Screen off
                            ; BG+SPR clipping
                            ; Colour display
    sta     ZPCtrl1
    sta     PPUCtrl1

    lda     #%10101000      ; NMI = enabled
                            ; Sprite size = 8x16
                            ; BG pattern table = $0000
                            ; SPR pattern table = $1000
                            ; PPU address increment = 1
                            ; Name table address = $2000
    sta     ZPCtrl0
    sta     PPUCtrl0

    lda     #0
    jsr     SetBank
    lda     #mrTitleInit
    sta     MainRoutine
    jmp     +

;-----------------------------[ The main loop ]-------------------------------

    @@MainLoop:
    jsr     UpdateTimers
    jsr     GoMainHandler
  + ; lda     ZPCtrl1
    jsr     WaitNMIPass
    jmp     @@MainLoop
.endp

.end
