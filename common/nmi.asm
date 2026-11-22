.include "game.h"
.include "common/mmc3.h"
.include "common/nes.h"
.include "common/joypad.h"
.include "common/nmi.h"
.include "common/ppu.h"
.include "sound/sequencer.h"

.codeseg

.public NMI

;------------------------[ Non Maskable Interrupt ]---------------------------

.proc NMI
    sei
    pha                     ; preserve A
    txa
    pha                     ; preserve X
    tya
    pha                     ; preserve Y

    lda     ZPCtrl1
    sta     PPUCtrl1
    ldy     FrameStat
    bne     @@NoNMIProcessing ; skip the next part if the frame couldn't
                            ; finish before the NMI was triggered
    iny
    sty     FrameStat
    inc     FrameCount
    jsr     CheckPPUWrite
; update PPU control register 0
    lda     ZPCtrl0
    sta     PPUCtrl0
; update scroll registers
    lda     PPUStat         ; reset H/V scroll flip flop
    lda     ScrollX
    sta     PPUScroll
    lda     ScrollY
    sta     PPUScroll
; perform sprite DMA
    lda     #$00
    sta     SPRAddr         ; reset SPR-RAM address
    lda     #$02
    sta     SPRDMAReg
; set CHR banks
    ldx     #$05
  - stx     MMC3_CTRL_REG
    lda     SelectedCHR,x
    sta     MMC3_PAGE_REG
    dex
    bpl     -
; set up IRQ if requested
    lda     IRQCount
    beq     @@NoIRQ
    sta     MMC3_IRQ_COUNTER_REG
    sta     MMC3_IRQ_LATCH_REG
    sta     MMC3_IRQ_ENABLE_REG
    @@NoIRQ:
; read da friggin joypad
    jsr     ReadJoypad0
; update sound
    lda     MMC3Ctrl
    pha
    lda     #6
    jsr     SwapBank        ; switch to Music Bank
    jsr     RNME_PlaySong
    jsr     ResetBank
    pla
    sta     MMC3Ctrl
    sta     MMC3_CTRL_REG
    @@NoNMIProcessing:
    pla
    tay                     ; restore Y
    pla
    tax                     ; restore X
    pla                     ; restore A
    rti
.endp

.end
