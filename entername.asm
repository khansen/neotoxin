.include "game.h"
.include "nes.h"
.include "rnme.h"
.include "area2d.h"
.include "entername.h"
.include "fade.h"
.include "gamedata.h"
.include "ngsl.h"
.include "palette.h"
.include "ppu.h"
.include "savegame.h"
.include "screendata.h"
.include "warp.h"

.codeseg

.public FlashCursorPal
.public EnterNameInit
.public EnterNameMain
.public StartNewGame
.public InitGameState
.public PerformNameChange

; EnterNameInit
; =============

.proc EnterNameInit
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     LetterCol
    sta     LetterRow
    sta     NamePos
    sta     IRQCount
    sta     ScrollX
    sta     ScrollY
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
; load Enter Name screen
    lda     #<EnterNameData
    ldy     #>EnterNameData
    jsr     WriteROMPPUString
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
;
    jsr     SetSavePtr
    ldx     #9
    ldy     #58
  - lda     [pData],y
    sta     NameStr,x
    dey
    dex
    bpl     -
    jsr     ShowName
; set up cursors
    lda     #$03    ; square
    sta     SPR_Tile
    lda     #0
    sta     SPR_Attrib
    jsr     SetLetterCursor
    lda     #183
    sta     SPR_PosY+4
    lda     #$03    ; square
    sta     SPR_Tile+4
    lda     #0
    sta     SPR_Attrib+4
    jsr     SetNameCursor
;
    inc     MainRoutine
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack
.endp

; EnterNameMain
; =============

.proc EnterNameMain
    jsr     FlashCursorPal
    lda     JoyFirst
    and     #btnSTART
    beq     +
;
    lda     #5
    cmp     LetterRow
    beq     ++
    sta     LetterRow
    lda     #11
  - sta     LetterCol
    rts
 ++ lda     #11
    cmp     LetterCol
    bne     -
    jmp     @@NameFinished

  + lda     JoyFirst
    and     #(btnA | btnB)
    beq     NoNameChange
    ldy     #4
    sty     SFX_Number+1
    and     #btnA
    bne     @@EnterLetter
; erase last letter
    ldy     NamePos
    bne     +
    ldy     #10
  + dey
    sty     NamePos
    lda     #0
    sta     NameStr,y
    jsr     ShowName
    jmp     SetNameCursor

    @@NameFinished:
; check that the name is valid (contains 1+ non-zero characters)
    ldy     #9
    lda     #0
  - ora     NameStr,y
    dey
    bpl     -
    cmp     #0
    bne     +
    rts
; name accepted
  + lda     NextRoutine
    sta     MainRoutine
    ldy     #5
    sty     SFX_Number+1
    jmp     PAL_FadeToBlack

    @@EnterLetter:
    lda     LetterRow
    asl
    asl
    asl
    asl
    ora     LetterCol
    tay
    lda     LetterTransTable,y
    cmp     #$FF
    beq     @@NameFinished

    ldy     NamePos
    sta     NameStr,y
    jsr     ShowName
    ldy     NamePos
    cpy     #9
    bne     +
    ldy     #255
  + iny
    sty     NamePos
.endp

.proc SetNameCursor
    lda     NamePos
    asl
    asl
    asl
    adc     #88
    sta     SPR_PosX+4
    jmp     FlashCursorPal

    NoNameChange:
    lda     JoyFirst
    and     #(btnLEFT | btnRIGHT)
    beq     @@NoLetterLeftRight
    ldy     #3
    sty     SFX_Number+1
    lsr
    bcs     @@LetterRight
; LEFT pressed
    ldy     LetterCol
    bne     +
    ldy     LetterRow
    bne     ++
    ldy     #6
 ++ dey
    sty     LetterRow
    ldy     #12
  + dey
    sty     LetterCol
    jmp     SetLetterCursor

    @@LetterRight:
    ldy     LetterCol
    cpy     #11
    bne     +
    ldy     LetterRow
    cpy     #5
    bne     ++
    ldy     #255
 ++ iny
    sty     LetterRow
    ldy     #255
  + iny
    sty     LetterCol
    jmp     SetLetterCursor

    @@NoLetterLeftRight:
    lda     JoyFirst
    and     #(btnUP | btnDOWN)
    beq     SetLetterCursor
    ldy     #3
    sty     SFX_Number+1
    and     #btnDOWN
    bne     @@LetterDown
; UP pressed
    ldy     LetterRow
    bne     +
    ldy     #6
  + dey
    sty     LetterRow
    jmp     SetLetterCursor

    @@LetterDown:
    ldy     LetterRow
    cpy     #5
    bne     +
    ldy     #255
  + iny
    sty     LetterRow
.endp

.proc SetLetterCursor
    lda     LetterRow
    asl
    asl
    asl
    asl
    adc     #55
    sta     SPR_PosY
    lda     LetterCol
    asl
    asl
    asl
    asl
    adc     #32
    sta     SPR_PosX
    rts
.endp

.proc FlashCursorPal
    lda     FrameCount
    and     #$03
    bne     +
    ldx     PPUStrIndex
    lda     #$3F
    sta     PPUString,x
    inx
    lda     #$11
    sta     PPUString,x
    inx
    lda     #1
    sta     PPUString,x
    inx
    lda     FlashPos
    and     #7
    sta     FlashPos
    inc     FlashPos
    tay
    lda     FlashTable,y
    sta     PPUString,x
    inx
    jmp     EndPPUString
  + rts
.endp

FlashTable:
.db $0F,$04,$14,$24,$34,$24,$14,$04

.proc ShowName
    ldx     PPUStrIndex
    lda     #$22
    sta     PPUString,x
    inx
    lda     #$EB
    sta     PPUString,x
    inx
    lda     #10
    sta     PPUString,x
    inx
    ldy     #0
  - lda     NameStr,y
    sta     PPUString,x
    inx
    iny
    cpy     #10
    bne     -
    jmp     EndPPUString
.endp

; PerformNameChange
; =================

.proc PerformNameChange
    jsr     SetSavePtr
    ldx     #9
    ldy     #58
  - lda     NameStr,x
    sta     [pData],y
    dey
    dex
    bpl     -
    jsr     CalcSaveGameCheckSum
    sta     [pData],y
    iny
    lda     Temp+1
    sta     [pData],y
    lda     #mrSelectGameInit
    sta     MainRoutine
    rts
.endp

; StartNewGame
; ============
; Start new game in slot (SaveSlot).

.proc StartNewGame
    jsr     InitGameState
    jsr     WriteSaveGame
    lda     #<IntroScript
    ldy     #>IntroScript
    jmp     LoadScript
.endp

; InitGameState
; =============
; Initializes player stats from InitialSaveGame and clears StatusFlags.
; Out: A = 0

.proc InitGameState
    ldx     #16
  - lda     InitialSaveGame,x
    sta     Health,x
    dex
    bpl     -
    lda     #0
    ldx     #31
  - sta     StatusFlags,x
    dex
    bpl     -
    rts
.endp

.end
