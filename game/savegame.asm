.include "game.h"
.include "main.h"
.include "game/savegame.h"
.include "engine/warp.h"

; SetSavePtr (engine/warp.asm) finds a slot by shifting the slot number left
; six times, and the WRAM format has 64-byte slots.
.if sizeof(save_slot) != 64
.error "save_slot must be 64 bytes"
.endif

.dataseg zeropage

SaveStats       .save_stats
NameStr         .byte[NAME_LENGTH]

.codeseg

.public SaveStats
.public NameStr
.public WriteSaveGame
.public LoadSaveGame
.public CalcSaveGameCheckSum

; WriteSaveGame
; =============

.proc WriteSaveGame
    jsr     SetSavePtr
    ldx     #0
    stx     Index
 -- lda     SaveGameInfo,x  ; # of bytes to copy
    beq     +
    sta     Count
    lda     SaveGameInfo+1,x
    sta     Temp
    lda     SaveGameInfo+2,x
    sta     Temp+1      ; starting location of data
    ldy     #0
    sty     Index2
  - ldy     Index2
    inc     Index2
    lda     [Temp],y
    ldy     Index
    inc     Index
    sta     [pData],y
    dec     Count
    bne     -
    inx
    inx
    inx
    bne     --
  + jsr     CalcSaveGameCheckSum
; store checksum
    sta     [pData],y
    iny
    lda     Temp+1
    sta     [pData],y
    rts
.endp

SaveGameInfo:
.db sizeof(save_stats) : .dw SaveStats
.db STATUS_FLAG_BYTES : .dw StatusFlags
.db NAME_LENGTH : .dw NameStr
.db 0

; LoadSaveGame
; ============
; A,Y = address of savegame to load

.proc LoadSaveGame
    jsr     SetSavePtr
    ldx     #0
    stx     Index
 -- lda     SaveGameInfo,x  ; # of bytes to copy
    beq     +
    sta     Count
    lda     SaveGameInfo+1,x
    sta     Temp
    lda     SaveGameInfo+2,x
    sta     Temp+1      ; starting location of data
    ldy     #0
    sty     Index2
  - ldy     Index
    inc     Index
    lda     [pData],y
    ldy     Index2
    inc     Index2
    sta     [Temp],y
    dec     Count
    bne     -
    inx
    inx
    inx
    bne     --
; verify checksum
  + jsr     CalcSaveGameCheckSum
    cmp     [pData],y
    bne     @@InvalidCheckSum
    iny
    lda     Temp+1
    cmp     [pData],y
    bne     @@InvalidCheckSum
; save game loaded successfully!
    rts
; save game data corrupted
    @@InvalidCheckSum:
    jmp     RESET
    rts
.endp

; CalcSaveGameCheckSum
; ====================
; In:  pData = address of save game
; Out: Temp = checksum of Stats, Flags and Name, Y = save_slot::Checksum

.proc CalcSaveGameCheckSum
    lda     #0
    sta     Temp
    sta     Temp+1
    tay
  - lda     [pData],y
    clc
    adc     Temp
    sta     Temp
    bcc     +
    inc     Temp+1
  + iny
    cpy     #save_slot::Name+NAME_LENGTH
    bne     -
    ldy     #save_slot::Checksum
    rts
.endp

.end
