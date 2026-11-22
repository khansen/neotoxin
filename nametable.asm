.include "game.h"
.include "hsge.h"
.include "nametable.h"
.include "ppu.h"
.include "scroller.h"

.codeseg

.public HSGE_WriteNameTableCol
.public HSGE_WriteNameTableRow

; HSGE_WriteNameTableCol
; ======================

.proc HSGE_WriteNameTableCol
    lda     HSGE_RoomOfs
    sta     Index
    lda     #1
    sta     HSGE_VRAMAddr
    lda     HSGE_ScreenRow
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    ora     HSGE_RoomCol
    sta     HSGE_VRAMAddr+1
    lda     HSGE_ScreenTable
    asl
    asl
    asl
    ora     HSGE_VRAMAddr
    sta     HSGE_VRAMAddr
    lda     #30     ; total number of bytes to write
    sta     Count
    sec
    sbc     HSGE_ScreenRow
    sta     Count2
    lda     HSGE_RoomRow
    and     #3
    asl
    asl
    sta     Temp
    lda     HSGE_VRAMAddr+1
    and     #3
    ora     Temp
    sta     Index2  ; macro index
    ldx     PPUStrIndex
  - lda     HSGE_VRAMAddr
    sta     PPUString+0,x   ; high nametable address
    lda     HSGE_VRAMAddr+1
    sta     PPUString+1,x   ; low nametable address
    lda     Count2
    ora     #$80
    sta     PPUString+2,x   ; # of bytes to write vertically
    inx
    inx
    inx
    lda     Count2
    sta     Count3
 -- ldy     Index
    lda     [HSGE_pRoom],y   ; macro #
    asl
    tay
    lda     [ah_pMacroPtrTable],y
    sta     HSGE_pMacro
    iny
    lda     [ah_pMacroPtrTable],y
    sta     HSGE_pMacro+1
    ldy     Index2
--- lda     [HSGE_pMacro],y
    sta     PPUString,x
    inx
    tya
    adc     #4
    tay
    and     #12
    bne     ++
    ; macro wrap
    tya
    and     #3      ; row = 0
    sta     Index2
    lda     Index
    adc     #8      ; next room row
    cmp     #64
    sta     Index
    bcc     +
    ; room wrap
    sbc     #64
    sta     Index
    lda     Temp4
    clc
    adc     MapWidth
    jsr     HSGE_SetRoomPtr
  + ldy     Index2
    dec     Count3
    beq     +
    bne     --
 ++ dec     Count3
    bne     ---
  + sty     Index2
    lda     Count
    sec
    sbc     Count2
    beq     +   ; exit if no more bytes to write
    sta     Count
    sta     Count2
    lda     HSGE_VRAMAddr
    and     #$28
    eor     #$08    ; switch to other nametable
    sta     HSGE_VRAMAddr
    lda     HSGE_VRAMAddr+1
    and     #$1F    ; row = 0
    sta     HSGE_VRAMAddr+1
    jmp     -
  + jmp     EndPPUString
.endp

; HSGE_WriteNameTableRow
; ======================

.proc HSGE_WriteNameTableRow
    lda     HSGE_RoomOfs
    sta     Index
    lda     #1
    sta     HSGE_VRAMAddr
    lda     HSGE_ScreenRow
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    asl
    rol     HSGE_VRAMAddr
    ora     HSGE_RoomCol
    sta     HSGE_VRAMAddr+1
    tya
    asl
    asl
    asl
    ora     HSGE_VRAMAddr
    sta     HSGE_VRAMAddr
    lda     #32     ; total # of bytes to write
    sta     Count
    sec
    sbc     HSGE_RoomCol
    sta     Count2  ; # of bytes to write on 1st pass
    ldx     PPUStrIndex
  - lda     HSGE_VRAMAddr
    sta     PPUString+0,x   ; high nametable address
    lda     HSGE_VRAMAddr+1
    sta     PPUString+1,x   ; low nametable address
    lda     Count2
    sta     PPUString+2,x   ; # of bytes to write
    inx
    inx
    inx
    lda     Count2
    sta     Count3  ; temp. counter
    lda     HSGE_TempRow
    and     #3
    asl
    asl
    sta     Temp
    lda     HSGE_VRAMAddr+1
    and     #3
    ora     Temp
    sta     Index2  ; macro index
 -- ldy     Index
    lda     [HSGE_pRoom],y   ; macro #
    asl
    tay
    bcc     +
    inc     ah_pMacroPtrTable+1
  + lda     [ah_pMacroPtrTable],y
    sta     HSGE_pMacro
    iny
    lda     [ah_pMacroPtrTable],y
    sta     HSGE_pMacro+1
    bcc     +
    dec     ah_pMacroPtrTable+1
  + ldy     Index2
--- lda     [HSGE_pMacro],y
    sta     PPUString,x
    inx
    dec     Count3
    beq     +
    iny
    tya
    and     #3
    bne     ---
    inc     Index
    lda     Index2
    and     #12
    sta     Index2
    bpl     --      ; branch always
  + lda     Count
    sec
    sbc     Count2
    beq     +   ; exit if no more bytes to write
    sta     Count
    sta     Count2
    lda     HSGE_VRAMAddr+1
    and     #$E0    ; column = 0
    sta     HSGE_VRAMAddr+1
    lda     Index
    and     #$F8    ; column = 0
    sta     Index
    ldy     Temp4
    iny
    tya
    jsr     HSGE_SetRoomPtr
    jmp     -
  + jmp     EndPPUString
.endp

.end
