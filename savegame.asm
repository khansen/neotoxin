.include "game.h"

.codeseg

.public WriteSaveGame
.public LoadSaveGame
.public CalcSaveGameCheckSum

.extrn SetSavePtr:proc
.extrn RESET:proc

; WriteSaveGame
; =============

    WriteSaveGame:
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

SaveGameInfo:
.db 17 : .dw Health
.db 32 : .dw StatusFlags
.db 10 : .dw NameStr
.db 0

; LoadSaveGame
; ============
; A,Y = address of savegame to load

    LoadSaveGame:
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
    bne     InvalidCheckSum
    iny
    lda     Temp+1
    cmp     [pData],y
    bne     InvalidCheckSum
; save game loaded successfully!
    rts
; save game data corrupted
    InvalidCheckSum:
    jmp     RESET
    rts

; CalcSaveGameCheckSum
; ====================
; pData = address of save game

    CalcSaveGameCheckSum:
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
    cpy     #59
    bne     -
    iny
    rts


.end
