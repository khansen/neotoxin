.include "game.h"
.include "engine/hsge.h"
.include "engine/attribtable.h"
.include "common/ppu.h"
.include "engine/scroller.h"
.include "engine/warp.h"

.codeseg

.public HSGE_WriteAttribTableCol
.public HSGE_WriteAttribTableRow

; HSGE_WriteAttribTableCol
; ========================

.proc HSGE_WriteAttribTableCol
    lda     HSGE_RoomOfs
    sta     Index
    lda     HSGE_ScreenTable    ; 0 or 1
    asl
    asl
    asl
    ora     #$23
    sta     HSGE_VRAMAddr   ; high address (23h or 2Bh)
    lda     HSGE_ScreenRow
    and     #$FC
    asl
    sta     Temp            ; (ScreenRow/4)*8
    lda     HSGE_RoomCol
    lsr
    lsr
    ora     Temp
    ldy     HSGE_ScreenTable
    beq     +
    ora     #64
  + sta     Index2  ; RAM table index: (ScreenRow/4)*8 + (RoomCol/4)
    ora     #$C0    ; attribute table begins at 23C0h/2BC0h
    sta     HSGE_VRAMAddr+1 ; low address
    lda     HSGE_RoomRow
    lsr
    sta     Index3  ; 1st room attribute row
    lda     HSGE_ScreenRow
    lsr
    sta     Index4  ; 1st attribute table row
    lda     #16     ; total # of 2x2 tile sectors to update
    sta     Count
    lda     HSGE_RoomCol
    asl
    and     #4
    sta     Temp3   ; attribcol*4
    ldx     PPUStrIndex
  - ldy     Index
    lda     [HSGE_pRoom],y  ; macro #
    tay
    lda     [ah_pMacroAttribTable],y
    sta     Temp
    lda     Index4
    lsr
    lda     Index3
    and     #1
    rol
    ora     Temp3
    tay
    lda     AttribLookupShift,y
    beq     +   ; no shift
    bmi     ++
    ; shift left
    lda     Temp
    asl
    asl
    asl
    asl
    jmp     +++
    ; shift right
 ++ lda     Temp
    lsr
    lsr
    lsr
    lsr
    bpl     +++
  + lda     Temp
+++ and     AttribLookupMask,y
    sta     Temp
    lda     AttribLookupMaskInv,y
    ldy     Index2
    and     $7000,y
    ora     Temp
    sta     $7000,y
    lda     Index4
    lsr
    bcc     +
    ; write byte to screen attribute table
 -- lda     HSGE_VRAMAddr
    sta     PPUString,x
    inx
    lda     HSGE_VRAMAddr+1
    sta     PPUString,x
    inx
    lda     #1
    sta     PPUString,x
    inx
    lda     $7000,y
    sta     PPUString,x
    inx
    lda     HSGE_VRAMAddr+1
    clc
    adc     #8      ; next screen attribute row offset
    sta     HSGE_VRAMAddr+1
    lda     Index2
    adc     #8
    sta     Index2
  + lda     Index3
    lsr
    bcc     +
    ; next room row
    lda     Index
    adc     #7
    sta     Index
  + inc     Index3  ; next room attribute row
    lda     Index3
    and     #15
    sta     Index3
    bne     +
    ; room wrap
    lda     Index
    and     #7      ; row = 0
    sta     Index
    lda     Temp4
    clc
    adc     MapWidth
    jsr     HSGE_SetRoomPtr
  + inc     Index4  ; next screen attribute row
    lda     Index4
    cmp     #15
    bne     +
    ; screen wrap
    lda     HSGE_VRAMAddr
    sta     PPUString,x
    inx
    lda     HSGE_VRAMAddr+1
    sta     PPUString,x
    inx
    lda     #1
    sta     PPUString,x
    inx
    ldy     Index2
    lda     $7000,y
    sta     PPUString,x
    inx
    lda     #0
    sta     Index4  ; row = 0
    lda     HSGE_VRAMAddr
    eor     #$08    ; switch to other nametable
    sta     HSGE_VRAMAddr
    lda     HSGE_VRAMAddr+1
    and     #7      ; row = 0
    ora     #$C0
    sta     HSGE_VRAMAddr+1
    lda     Index2
    and     #71      ; row = 0
    eor     #64     ; switch to other RAM attribute table
    sta     Index2
  + dec     Count
    bmi     +
    beq     ++
    jmp     -
 ++ lda     Index4
    lsr
    bcc     +
    ldy     Index2
    jmp     --
  + jmp     EndPPUString
.endp

AttribLookupShift:
.db 0,1,-1,0,0,1,-1,0
AttribLookupMask:
.db %00000011,%00110000,%00000011,%00110000,%00001100,%11000000,%00001100,%11000000
AttribLookupMaskInv:
.db %11111100,%11001111,%11111100,%11001111,%11110011,%00111111,%11110011,%00111111

; HSGE_WriteAttribTableRow
; ========================

.proc HSGE_WriteAttribTableRow
    lda     HSGE_RoomOfs
    sta     Index
    tya
    asl
    asl
    asl
    ora     #$23
    sta     HSGE_VRAMAddr   ; high address (23h or 2Bh)
    lda     HSGE_ScreenRow
    and     #$FC
    asl
    sta     Temp            ; (ScreenRow/4)*8
    lda     HSGE_RoomCol
    lsr
    sta     Index3  ; 1st attribcol
    lsr
    ora     Temp
    cpy     #0      ; screentable = 0?
    beq     +
    ora     #64
  + sta     Index2  ; RAM table index: (ScreenRow/4)*8 + (RoomCol/4)
    ora     #$C0    ; attribute table begins at 23C0h/2BC0h
    sta     HSGE_VRAMAddr+1 ; low address
    lda     HSGE_ScreenRow
    lsr
    lsr     ; screen attribute row bit 0 in carry
    php
    lda     HSGE_TempRow
    lsr     ; room attribute row bit 0 in bit 0
    plp
    rol
    and     #3
    sta     Temp3
    lda     #16     ; total # of 2x2 tile sectors to update
    sta     Count
    ldx     PPUStrIndex
  - ldy     Index
    lda     [HSGE_pRoom],y  ; macro #
    tay
    lda     [ah_pMacroAttribTable],y
    sta     Temp
    lda     Index3  ; attribcol
    and     #1
    asl
    asl
    ora     Temp3
    tay
    lda     AttribLookupShift,y
    beq     +   ; no shift
    bmi     ++
    ; shift left
    lda     Temp
    asl
    asl
    asl
    asl
    jmp     +++
    ; shift right
 ++ lda     Temp
    lsr
    lsr
    lsr
    lsr
    bpl     +++
  + lda     Temp
+++ and     AttribLookupMask,y
    sta     Temp
    lda     AttribLookupMaskInv,y
    ldy     Index2
    and     $7000,y
    ora     Temp
    sta     $7000,y
    lda     Index3
    lsr
    bcc     +
    ; write byte to screen attribute table
 -- lda     HSGE_VRAMAddr
    sta     PPUString,x
    inx
    lda     HSGE_VRAMAddr+1
    sta     PPUString,x
    inx
    lda     #1
    sta     PPUString,x
    inx
    lda     $7000,y
    sta     PPUString,x
    inx
    inc     HSGE_VRAMAddr+1 ; next screen attribute table byte address
    inc     Index2
    inc     Index    ; next room column
  + inc     Index3
    lda     Index3
    and     #15
    sta     Index3
    bne     +
    ; room wrap
    lda     HSGE_RoomOfs
    and     #$F8    ; column = 0
    sta     Index
    lda     HSGE_VRAMAddr+1
    sec
    sbc     #8      ; column = 0
    sta     HSGE_VRAMAddr+1
    lda     Index2
    sec
    sbc     #8
    sta     Index2
    ldy     Temp4
    iny
    tya
    jsr     HSGE_SetRoomPtr
  + dec     Count
    bmi     +
    beq     ++
    jmp     -
 ++ lda     Index3
    lsr
    bcc     +
    ldy     Index2
    jmp     --
  + jmp     EndPPUString
.endp

.end
