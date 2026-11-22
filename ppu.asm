.include "game.h"
.include "nes.h"

.codeseg

.public ScreenOff
.public ClearDisplay
.public LoadCHR
.public ScreenOn
.public EndPPUString
.public WaitNMIPass
.public WriteRAMPPUString
.public WriteROMPPUString
.public Return
.public CheckPPUWrite
.public FrameDelay
.public UpdateTimers
.public Load2DAreaHdr
.public WritePPUString

.extrn AreaHdrTable:label
.extrn DestroyAllSprites:proc

; PPU / VRAM helper routines, plus Load2DAreaHdr and UpdateTimers
; (kept in this unit to preserve the original Bank 7 routine order).

; Load2DAreaHdr
; =============
; In: A = Area to load

    Load2DAreaHdr:
    asl
    tax
    lda     AreaHdrTable,x
    sta     pData
    lda     AreaHdrTable+1,x
    sta     pData+1
    ldy     #18     ; header length - 1
  - lda     [pData],y
    sta     ah_AreaBank,y
    dey
    bpl     -
    rts

; LoadCHR
; =======
; Sets the eight 1K CHR pages to use when drawing the screen.
; In: A = low data address.
;     Y = high data address.

    LoadCHR:
    sta     pData
    sty     pData+1
    ldy     #$05
  - lda     [pData],y
    sta     SelectedCHR,y
    dey
    bpl     -
    rts

; AnimateCHR
; ==========

;    AnimateCHR:
;    lda     CHRAnimStat
;    beq     +
;    dec     CHRAnimDelay
;    bpl     +
;    lda     #CHRANIM_SPEED-1
;    sta     CHRAnimDelay
;    inc     CHRAnimFrame
;    lda     CHRAnimFrame
;    and     #$07
;    clc
;    adc     CHRAnimStat
;    sta     SelectedCHR+5
;  + rts

; ScreenOff
; =========
; Turns off both background and sprites, so that VRAM can safely be written
; to.

    ScreenOff:
    lda     ZPCtrl1
    and     #%11100111      ; bg & sprite visibility = false
    sta     ZPCtrl1

; WaitNMIPass
; ===========
; Hangs around until the NMI has finished.
; NMI *must* be enabled when this routine is called, otherwise it will go
; into an infinite loop.

    WaitNMIPass:
    lda     #$00
    sta     FrameStat
  - lda     FrameStat
    beq     -
    rts

; FrameDelay
; ==========
; Y = # of frames to delay

    FrameDelay:
  - jsr     WaitNMIPass
    dey
    bne     -
    rts

; ScreenOn
; ========
; Enables both background and sprites.

    ScreenOn:
    lda     ZPCtrl1
    ora     #%00011000      ; bg & sprite visibility = true
    sta     ZPCtrl1
    bne     WaitNMIPass

; UpdateTimers
; ============
; Decrements Timer every (1/60)*TIMER_SPEED seconds (AKA every TIMER_SPEEDth
; frame), if it isn't already zero.

    UpdateTimers:
    dec     TimerDelay
    bpl     ++
    lda     #TIMER_SPEED-1
    sta     TimerDelay
    ldx     #$07            ; 8 timers to update
  - lda     Timer,x
    beq     +               ; don't modify if already zero
    dec     Timer,x
  + dex                     ; next timer
    bpl     -
 ++ rts

; ClearDisplay
; ============
; Clears both nametables and destroys all sprites.

    ClearDisplay:
    ldx     #$00            ; nametable 0
    jsr     FillNameTable
    ldx     #$01            ; nametable 1
    jsr     FillNameTable
    ldx     #$02            ; nametable 2
    jsr     FillNameTable
    jmp     DestroyAllSprites

; FillNameTable
; =============
; Fills name table with value BLANK_TILE. The corresponding attribute table
; is filled with 00s.
; X = name table # (0..3)

    FillNameTable:
    lda     ZPCtrl0
    and     #%11111011      ; PPU increment = 1
    sta     ZPCtrl0
    sta     PPUCtrl0
    txa                     ; A = nametable
    asl
    asl
    ora     #$20            ; high PPU address
    ldx     PPUStat         ; reset PPU address flip flop
    sta     PPUAddr
    lda     #$00
    sta     PPUAddr
    ldy     #$C0
    ldx     #$04
    lda     #BLANK_TILE     ; fill with this value
  - sta     PPUIOReg
    dey
    bne     -
    dex
    bne     -
    ldy     #$40            ; attribute table size = $40 bytes
    txa                     ; A = 0
  - sta     PPUIOReg
    dey
    bne     -
    rts

; WritePPUString
; ==============
; Writes a sequence of data strings to VRAM.
; pData: ptr to first string
; -------------
; String format:
; byte 0: high byte of PPU address
; byte 1: low byte of PPU address
; byte 2: bits 0-5 length of data string (repeat count if RLE)
;         bit 6 is data RLE? (1 = yes)
;         bit 7 PPU address increment (0 = 1, 1 = 32)
; byte 3-..: data. Only 1 byte if string is RLE
; -------------
; When byte 0 is zero, it means that no more strings remain to be written.

  - ldx     PPUStat         ; reset PPU address flip flop
    sta     PPUAddr         ; set PPU hi address
    pha                     ; save it for later
    iny
    lda     [pData],y
    sta     PPUAddr         ; set PPU lo address
    iny
    lda     [pData],y       ; string info byte
    asl                     ; CF = PPU address increment
    tax
    lda     ZPCtrl0
    ora     #%00000100
    bcs     +               ; if CF set, PPU inc = 32
    and     #%11111011      ; else PPU inc = 1
  + sta     ZPCtrl0
    sta     PPUCtrl0
    txa
    asl                     ; CF = RLE status (1 = RLE)
    lda     [pData],y       ; string info byte again
    and     #$3F            ; data length in lower 6 bits
    tax                     ; use as loop counter
    bcc     PPUWriteLoop    ; branch if string isn't RLE
    iny
    lda     [pData],y       ; fetch the RLE data byte
    PPURepeatLoop:
    sta     PPUIOReg
    dex
    bne     PPURepeatLoop
    beq     +
    PPUWriteLoop:
    iny
    lda     [pData],y       ; fetch the next data byte
    sta     PPUIOReg        ; write to PPU
    dex
    bne     PPUWriteLoop
  + pla                     ; restore PPU hi address
    cmp     #$3F            ; was the data written to page $3F?
    bne     +               ; branch if not
    sta     PPUAddr
    stx     PPUAddr
    stx     PPUAddr
    stx     PPUAddr
  + tya                     ; A = string length - 1
    sec                     ; set carry, so we are adding actual strlen
    adc     pData           ; add to pointer
    sta     pData           ; pData now points to the next string
    bcc     WritePPUString
    inc     pData+1
    WritePPUString:
    ldy     #$00
    lda     [pData],y
    bne     -               ; non-zero = valid string, write it
  - rts

; CheckPPUWrite
; =============
; Writes any data waiting to be written to VRAM.

    CheckPPUWrite:
    ldy     PPUDataPending
    beq     -               ; exit if no data pending
    dey                     ; Y = 0
    sty     PPUStrIndex
    sty     PPUDataPending
    WriteRAMPPUString:
    lda     #<PPUString
    sta     pData
    lda     #>PPUString
    sta     pData+1
    jmp     WritePPUString

; WriteROMPPUString
; =================
; In: A = low address.
;     Y = high address.

    WriteROMPPUString:
    sta     pData
    sty     pData+1
    jmp     WritePPUString

; EndPPUString
; ============

    EndPPUString:
    stx     PPUStrIndex
    lda     #$00
    sta     PPUString,x
    lda     #$01
    sta     PPUDataPending
    Return:
    rts


.end
