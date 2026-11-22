.include "game.h"
.include "engine/hsge.h"
.include "common/nes.h"
.include "common/fade.h"
.include "game/gamedata.h"
.include "common/mmc3.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "screens/screendata.h"
.include "screens/statusscreen.h"
.include "engine/anim.h"
.include "chr/chr.h"
.include "engine/obj.h"
.include "engine/area2d.h"
.include "engine/renderer.h"
.include "engine/warp.h"

.dataseg zeropage

AC0                 .byte   ; PrintValue: value to print (24 bits), quotient
AC1                 .byte
AC2                 .byte
XTND0               .byte   ; remainder
XTND1               .byte
XTND2               .byte
AUX0                .byte   ; divisor
AUX1                .byte
AUX2                .byte
TMP0                .byte

.codeseg

.public AC0
.public AC1
.public AC2
.public PrintValue
.public UpdateClock
.public CheckPause
.public StatusMain
.public ExitStatusScreen
.public ResumeArea

; UpdateClock
; ===========

.proc UpdateClock
    inc     ClockTicks
    lda     ClockTicks
    cmp     #60
    bne     +
    ldy     #0
    sty     ClockTicks
    inc     Seconds
    lda     Seconds
    cmp     #60
    bne     +
    sty     Seconds
    inc     Minutes
    lda     Minutes
    cmp     #60
    bne     +
    sty     Minutes
    inc     Hours
  + rts
.endp

; ShowClock
; =========
; Print the clock on the screen, in format HH:MM:SS

.proc ShowClock
    lda     #$21
    sta     PPUString
    lda     #$0B
    sta     PPUString+1
    lda     #8
    sta     PPUString+2
    lda     #<(PPUString+3)
    sta     pData
    lda     #>(PPUString+3)
    sta     pData+1
    ldy     #2          ; tells HexToDec to output 2 digits
; show hours
    lda     Hours
    jsr     HexToDec
    lda     #$C5        ; ':'
    sta     [pData],y
    lda     pData
    clc
    adc     #3
    sta     pData
; show minutes
    lda     Minutes
    jsr     HexToDec
    lda     #$C5        ; ':'
    sta     [pData],y
    lda     pData
    clc
    adc     #3
    sta     pData
; show seconds
    lda     Seconds
    jsr     HexToDec
    lda     #$00
    sta     PPUString+11
    lda     #<PPUString
    sta     pData
    jmp     WritePPUString
.endp

; PrintValue
; ==========
; AC0, AC1, AC2 = value to print
; X = # of digits to output (0 = as many as needed)
; A = PPU high address
; Y = PPU low address

.proc PrintValue
    stx     Count
    ldx     PPUStrIndex
    sta     PPUString,x
    inx
    tya
    sta     PPUString,x
    inx
    lda     #10
    sta     AUX0
    lda     #0
    sta     AUX1
    sta     AUX2
    ldy     Count
    cpy     #0
    bne     +
; figure out how many digits to print
  - iny
    cpy     #7
    beq     +
    lda     AC0
    sec
    sbc     DecPos0-1,y
    lda     AC1
    sbc     DecPos1-1,y
    lda     AC2
    sbc     DecPos2-1,y
    bcs     -
  + sty     Count
    tya
    sta     PPUString,x
    inx
  - jsr     Divide
    lda     XTND0
    pha
    dey
    bne     -
  - pla
    ora     #$80
    sta     PPUString,x
    inx
    iny
    cpy     Count
    bne     -
    jmp     EndPPUString
.endp

DecPos0:
.db $0A,$64,$E8,$10,$A0,$40
DecPos1:
.db $00,$00,$03,$27,$86,$42
DecPos2:
.db $00,$00,$00,$00,$01,$0F

.proc Divide
    txa
    pha
    tya
    pha
    ldy #24      ; bitwidth
    lda #0
    sta XTND0
    sta XTND1
    sta XTND2
  - asl AC0      ;DIVIDEND/2, CLEAR QUOTIENT BIT
    rol AC1
    rol AC2
    rol XTND0
    rol XTND1
    rol XTND2
    lda XTND0    ;TRY SUBTRACTING DIVISOR
    sec
    sbc AUX0
    sta TMP0
    lda XTND1
    sbc AUX1
    tax
    lda XTND2
    sbc AUX2
    bcc +        ;TOO SMALL, QBIT=0
    stx XTND1    ;OKAY, STORE REMAINDER
    sta XTND2
    lda TMP0
    sta XTND0
    inc AC0      ;SET QUOTIENT BIT = 1
  + dey          ;NEXT STEP
    bne -
    pla
    tay
    pla
    tax
    rts
.endp

; HexToDec
; ========
; In: A = number to convert
;     Y = # of digits out
; pData = where to store result

.proc HexToDec
    sty     Count2
  - jsr     DivBy10
    pha
    txa
    dey
    bne     -
  - pla
    ora     #$80
    sta     [pData],y
    iny
    cpy     Count2
    bne     -
    rts
.endp

; DivBy10
; =======
; Divides an 8-bit number by 10.
; In: A = number to divide
; Out: X = Quotient
;      A = Remainder

.proc DivBy10
    ldx     #0  ; clear quotient
  - cmp     #10
    bcc     +
    sbc     #10
    inx
    bne     -
  + rts
.endp

; CheckPause
; ==========
; Checks if START has been pressed, and if so, loads status screen.

.proc CheckPause
    lda     JoyFirst
    and     #btnSTART
    bne     @@GoStatusScreen
    rts
; enter status screen
    @@GoStatusScreen:
    jsr     WaitNMIPass
    lda     #0
    sta     HSGE_QueueSize
    jsr     PAL_FadeToBlack
    jsr     ScreenOff
; init status screen
    lda     #0
    jsr     SetBank
    sta     IRQCount
    sta     ScrollX
    sta     ScrollY
    lda     ZPCtrl0
    sta     HSGE_Temp2000   ; preserve screen settings
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
    jsr     ClearDisplay
; set up status screen window
    lda     #<StatusScreenData
    ldy     #>StatusScreenData
    jsr     WriteROMPPUString
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
; set up individual status screen components
; clock
    jsr     ShowClock
; health
    lda     Health
    sta     AC0
    ldx     #0
    stx     AC1
    stx     AC2
    ldy     #$6D
    lda     #$21
    jsr     PrintValue
    jsr     CheckPPUWrite
; maxhealth
    lda     MaxHealth
    sta     AC0
    ldx     #0
    ldy     #$71
    lda     #$21
    jsr     PrintValue
    jsr     CheckPPUWrite
; defense
    lda     Defense
    sta     AC0
    ldx     #0
    ldy     #$AF
    lda     #$21
    jsr     PrintValue
    jsr     CheckPPUWrite
; level
    lda     Level
    sta     AC0
    ldx     #0
    ldy     #$0E
    lda     #$22
    jsr     PrintValue
    jsr     CheckPPUWrite
; experience
    lda     Experience
    sta     AC0
    lda     Experience+1
    sta     AC1
    ldx     #0
    ldy     #$6C
    lda     #$22
    jsr     PrintValue
    jsr     CheckPPUWrite
; next
    lda     Level
    asl
    tay
    lda     ExpPtsLevelTable,y
    sec
    sbc     Experience
    sta     AC0
    lda     ExpPtsLevelTable+1,y
    sbc     Experience+1
    sta     AC1
    ldx     #0
    ldy     #$AC
    lda     #$22
    jsr     PrintValue
    jsr     CheckPPUWrite

; show status screen
    jsr     ScreenOn
    jsr     PAL_FadeFromBlack
    lda     #mrStatusMain
    sta     MainRoutine
    rts
.endp

; StatusMain
; ==========

.proc StatusMain
    lda     JoyFirst
    and     #btnSTART
    bne     ExitStatusScreen
    rts
.endp

; ExitStatusScreen
; ================
; Fades out the status screen and returns to the area.

.proc ExitStatusScreen
    jsr     PAL_FadeToBlack
    ; falls through to ResumeArea
.endp

; ResumeArea
; ==========
; Redraws the current area and fades it in, then continues Area2DMain.

.proc ResumeArea
    jsr     ScreenOff
    jsr     Load2DArea
    jsr     RestoreAreaScreen
    jsr     Area2DMain   ; just so objects are drawn during fade-in
    lda     #231
    sta     IRQCount
    jsr     ScreenOn
    jsr     PAL_FadeFromBlack
    lda     #mrArea2DMain
    sta     MainRoutine
    rts
.endp

; RestoreAreaScreen
; =================

.proc RestoreAreaScreen
; restore Area CHR
    lda     ah_AreaCHR
    sta     SelectedCHR
    lda     ah_AreaCHR+1
    sta     SelectedCHR+1
    lda     #CHR_STATUS
    sta     SelectedCHR+3
; restore sprite CHR
    ldx     #23
  - lda     OBJ_Type,x
    bmi     +
    lda     ANIM_Cel,x
    jsr     ANIM_SetCel
  + dex
    bpl     -
; restore Area palette
    lda     ah_pAreaPalette
    ldy     ah_pAreaPalette+1
    jsr     PAL_LoadPalette
    jsr     SetHealthPal
; restore screen settings
    lda     HSGE_Temp2000
    sta     ZPCtrl0
; restore Area screen
    dec     HSGE_MapOfs
    jmp     HSGE_RenderScreen
.endp

.end
