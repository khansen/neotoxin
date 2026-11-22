.include "game.h"
.include "nes.h"
.include "ngsl.h"
.include "rnme.h"

.codeseg

.public IntroScript
.public ZombieScript
.public NPC6Script
.public SaveScript
.public Boss0IntroScript
.public Boss1IntroScript
.public Item0PickupScript
.public Item1PickupScript
.public Item2PickupScript
.public Item3PickupScript
.public Item4PickupScript
.public Item5PickupScript
.public Item6PickupScript
.public Item7PickupScript
.public NGSL_ExecScript

.extrn GoRoutine:proc
.extrn PAL_FadeFromBlack:proc
.extrn PAL_FadeToBlack:proc
.extrn ScreenOn:proc
.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn PAL_SetPalette:proc
.extrn WriteSaveGame:proc
.extrn SetStatusFlag:proc
.extrn ResetStatusFlag:proc
.extrn GetStatusFlag:proc
.extrn XSIGN:proc
.extrn HuffInit:proc
.extrn HuffDecodeByte:proc
.extrn EndPPUString:proc
.extrn WaitNMIPass:proc
.extrn FlashCursorPal:proc
.extrn ExitStatusScreen:proc
.extrn WriteRAMPPUString:proc

; NGSL_ExecScript
; ===============

    NGSL_ExecScript:
    jsr     NGSL_GetScriptByte
    jsr     NGSL_GoScriptOpcode
    jmp     NGSL_ExecScript

; NGSL_GoScriptOpcode
; ===================

    NGSL_GoScriptOpcode:
    jsr     GoRoutine

.db >(NGSL_ScriptEnd-1),       <(NGSL_ScriptEnd-1)
.db >(NGSL_ScriptSetFlag-1),   <(NGSL_ScriptSetFlag-1)
.db >(NGSL_ScriptResetFlag-1), <(NGSL_ScriptResetFlag-1)
.db >(NGSL_ScriptJmpIfFlag-1), <(NGSL_ScriptJmpIfFlag-1)
.db >(NGSL_ScriptJmpIfNFlag-1), <(NGSL_ScriptJmpIfNFlag-1)
.db >(NGSL_ScriptJmp-1),        <(NGSL_ScriptJmp-1)
.db >(NGSL_ScriptPrintMsg-1),  <(NGSL_ScriptPrintMsg-1)
.db >(NGSL_ScriptPlaySong-1),  <(NGSL_ScriptPlaySong-1)
.db >(NGSL_ScriptGoArea-1),     <(NGSL_ScriptGoArea-1)
.db >(NGSL_ScriptLoadPic-1),    <(NGSL_ScriptLoadPic-1)
.db >(PAL_FadeFromBlack-1),     <(PAL_FadeFromBlack-1)
.db >(PAL_FadeToBlack-1),     <(PAL_FadeToBlack-1)
.db >(NGSL_ScriptTextSpeed-1),  <(NGSL_ScriptTextSpeed-1)
.db >(ScreenOn-1), <(ScreenOn-1)
.db >(ScreenOff-1), <(ScreenOff-1)
.db >(NGSL_ScriptDelay-1),  <(NGSL_ScriptDelay-1)
.db >(ClearDisplay-1),  <(ClearDisplay-1)
.db >(NGSL_ScriptGoScript-1),   <(NGSL_ScriptGoScript-1)
.db >(NGSL_ScriptPrintMsgX-1),  <(NGSL_ScriptPrintMsgX-1)
.db >(NGSL_ScriptMultChoice-1), <(NGSL_ScriptMultChoice-1)
.db >(PAL_SetPalette-1),     <(PAL_SetPalette-1)
.db >(NGSL_ScriptSetTitle-1),   <(NGSL_ScriptSetTitle-1)
.db >(WriteSaveGame-1),    <(WriteSaveGame-1)
.db >(NGSL_PlaySfx-1),      <(NGSL_PlaySfx-1)

; NGSL_ScriptEnd
; ==============

    NGSL_ScriptEnd:
    pla
    pla
    rts

; NGSL_ScriptSetFlag
; ==================

    NGSL_ScriptSetFlag:
    jsr     NGSL_GetScriptByte  ; flag # to set
    jmp     SetStatusFlag

; NGSL_ScriptResetFlag
; ====================

    NGSL_ScriptResetFlag:
    jsr     NGSL_GetScriptByte  ; flag # to reset
    jmp     ResetStatusFlag

; NGSL_ScriptJmpIfFlag
; ====================

    NGSL_ScriptJmpIfFlag:
    jsr     NGSL_GetScriptByte  ; flag # to test
    jsr     GetStatusFlag
    bne     NGSL_ScriptJmp      ; branch if flag is set (=1=nonzero)
    jmp     NGSL_GetScriptByte  ; else skip branch amount

; NGSL_ScriptJmpIfNFlag
; =====================

    NGSL_ScriptJmpIfNFlag:
    jsr     NGSL_GetScriptByte  ; flag # to test
    jsr     GetStatusFlag
    beq     NGSL_ScriptJmp      ; branch if flag is not set (=0=zero)
    jmp     NGSL_GetScriptByte  ; else skip branch amount

; NGSL_ScriptJmp
; ==============

    NGSL_ScriptJmp:
    jsr     NGSL_GetScriptByte  ; relative branch amount
    cmp     #$80                ; branch backwards?
    bcs     NGSL_ScriptBranchBack
    ; branch forwards
    adc     NGSL_pScript
    sta     NGSL_pScript
    bcc     +
    inc     NGSL_pScript
    rts
    NGSL_ScriptBranchBack:
    jsr     XSIGN
    sta     NGSL_Temp
    lda     NGSL_pScript
    sec
    sbc     NGSL_Temp
    sta     NGSL_pScript
    bcs     +
    dec     NGSL_pScript
  + rts

; NGSL_ScriptPrintMsg
; ===================

    NGSL_ScriptPrintMsg:
    ; get string id
    jsr     NGSL_GetScriptByte
    asl
    tay
    lda     StringTable,y
    pha
    lda     StringTable+1,y
    tay
    pla
    jsr     HuffInit

    NGSL_BeginSection:
    ; default text speeds
    lda     #6
    sta     NGSL_TextSpeed
    lda     #1
    sta     NGSL_CharsPerFrame
;
    jsr     NGSL_ClearText
    lda     #$22
    sta     NGSL_LineAddr ; high vram address
;    jsr     NGSL_GetDataItemByte
    lda     #$64
    sta     NGSL_LineAddr+1
    sta     NGSL_Temp
    lda     NGSL_CharsPerFrame
    sta     Count

    NGSL_BeginTextChunk:
    lda     #0
    sta     Count2
    ldx     PPUStrIndex
    lda     NGSL_LineAddr
    sta     PPUString,x
    inx
    lda     NGSL_Temp
    sta     PPUString,x
    inx
    stx     Index
    inx

    NGSL_PrintLoop:
    stx     Index2
    jsr     HuffDecodeByte
    ldx     Index2
    cmp     #$FD                    ; if it's < FD...
    bcc     NGSL_PrintChar          ; it's a normal char, print it
    pha
    lda     Count2
    beq     +
    ldy     Index
    sta     PPUString,y
    jsr     EndPPUString
  + pla
    cmp     #$FD
    beq     NGSL_NewLine            ; FD = break to next line
    cmp     #$FE
    beq     NGSL_NewSection         ; FE = section done
    ; $FF = end of text
    rts

    NGSL_PrintChar:
    sta     PPUString,x             ; character to write
    inx
    inc     Count2
    dec     Count                   ; allowed to print more chars this frame?
    bne     NGSL_PrintLoop          ; branch if yes
; finish the PPU string
    ldy     Index
    lda     Count2
    sta     PPUString,y
    clc
    adc     NGSL_Temp
    sta     NGSL_Temp
    jsr     EndPPUString
;
    ldy     NGSL_TextSpeed
  - jsr     WaitNMIPass
    ; check for keypress
    lda     JoyFirst
    and     #(btnA | btnSTART)
    beq     +
    lda     #1  ; switch to fast textspeed
    sta     NGSL_TextSpeed
    lda     #32
    sta     NGSL_CharsPerFrame
  + dey
    bne     -
; print rest of text
    lda     NGSL_CharsPerFrame
    sta     Count
    jmp     NGSL_BeginTextChunk

    NGSL_NewLine:
    lda     NGSL_LineAddr+1
    clc
    adc     #32
    sta     NGSL_LineAddr+1
    sta     NGSL_Temp
    bcc     +
    inc     NGSL_LineAddr
  + jmp     NGSL_BeginTextChunk

    NGSL_NewSection:
    jsr     NGSL_CursorWaitKey
    jmp     NGSL_BeginSection

    NGSL_CursorWaitKey:
    lda     #$05      ; arrow down
    sta     SPR_Tile
    lda     #216
    sta     SPR_PosX
;    lda     PPUString+1
;    and     #$E0
;    lsr
;    lsr
;    clc
;    adc     #127+8
    lda     #199
    sta     SPR_PosY
    lda     #0
    sta     SPR_Attrib
  - jsr     WaitNMIPass
    jsr     FlashCursorPal
    lda     JoyFirst
    and     #(btnA | btnSTART)
    beq     -
    lda     #$F4
    sta     SPR_PosY
    rts

; NGSL_ClearText
; ==============

    NGSL_ClearText:
    lda     #$22
    sta     NGSL_LineAddr ; high vram address
    lda     #$64
    sta     NGSL_LineAddr+1
    lda     #24+64      ; repeat count = 24
    sta     PPUString+2
    lda     #0          ; blank tile
    sta     PPUString+3
    sta     PPUString+4
  - lda     NGSL_LineAddr
    sta     PPUString
    lda     NGSL_LineAddr+1
    sta     PPUString+1
    lda     #1
    sta     PPUDataPending
    jsr     WaitNMIPass
    lda     NGSL_LineAddr+1
    clc
    adc     #32
    sta     NGSL_LineAddr+1
    bcc     +
    inc     NGSL_LineAddr
  + lda     NGSL_LineAddr
    cmp     #$23
    bcc     -
    lda     NGSL_LineAddr+1
    cmp     #$40
    bcc     -
    rts

; NGSL_ScriptPlaySong
; ===================

    NGSL_ScriptPlaySong:
    jsr     NGSL_GetScriptByte  ; song # to play
    sta     RNME_LoadTune
    rts

; NGSL_PlaySfx:
; =============

    NGSL_PlaySfx:
    jsr     NGSL_GetScriptByte  ; channel # in upper 2 bits, effect # in lower 6
    pha
    rol
    rol
    rol
    and     #$03
    tay
    pla
    and     #$3F
    sta     SFX_Number,y
    rts

; NGSL_ScriptGoArea
; =================

    NGSL_ScriptGoArea:
    jsr     NGSL_GetScriptByte  ; area # to warp to
    cmp     #$FF
    bne     +
    ; return to current area location
    pla
    pla
    jmp     ExitStatusScreen+3
  + pha
    and     #$1F
    sta     CurrentSection
    pla
    lsr
    lsr
    lsr
    lsr
    lsr
    sta     CurrentArea
    jsr     NGSL_GetScriptByte  ; warp #
    sta     CurrentWarp
    lda     #mrExecWarp
    sta     MainRoutine
    pla
    pla
    rts

; NGSL_ScriptLoadPic
; ==================

    NGSL_ScriptLoadPic:
    ; get picture id
    jsr     NGSL_GetScriptByte
    asl
    tay
    lda     PicTable,y
    sta     NGSL_pDataItem
    lda     PicTable+1,y
    sta     NGSL_pDataItem+1
    ; load the 2K CHR bank for the picture
    jsr     NGSL_GetDataItemByte
    sta     SelectedCHR
    ; write nametable data
    lda     #$21    ; high vram address
    sta     NGSL_Temp  
    lda     #$08    ; low vram address
    sta     NGSL_Temp+1
    lda     #0
    sta     NGSL_Temp+2
    lda     #16     ; picture width
    sta     PPUString+2
    lda     #8      ; picture is 8 rows high
  - pha
    lda     NGSL_Temp
    sta     PPUString
    lda     NGSL_Temp+1
    sta     PPUString+1
    ldx     #0
    ldy     #16     ; picture is 16 columns wide
 -- lda     NGSL_Temp+2  ; tile #
    inc     NGSL_Temp+2
    sta     PPUString+3,x
    inx
    dey
    bne     --
    lda     #0
    sta     PPUString+3,x
    jsr     WriteRAMPPUString
    lda     NGSL_Temp+1
    clc
    adc     #32     ; next row
    sta     NGSL_Temp+1
    bcc     +
    inc     NGSL_Temp
  + pla
    sec
    sbc     #1
    bne     -
    ; write palette data
    ldx     #$04
  - jsr     NGSL_GetDataItemByte
    sta     RAMPalette,x
    inx
    cpx     #$10
    bne     -
    ; write attribute data
    lda     #$23
    sta     NGSL_Temp
    lda     #$D2
    sta     NGSL_Temp+1
    lda     #4
    sta     PPUString+2
    lda     #0
    sta     PPUString+7
    lda     #2
  - pha
    lda     NGSL_Temp
    sta     PPUString
    lda     NGSL_Temp+1
    sta     PPUString+1
    ldx     #0
 -- jsr     NGSL_GetDataItemByte
    sta     PPUString+3,x
    inx
    cpx     #4
    bne     --
    lda     #0
    sta     PPUString+3,x
    jsr     WriteRAMPPUString
    lda     NGSL_Temp+1
    clc
    adc     #8
    sta     NGSL_Temp+1
    pla
    sec
    sbc     #1
    bne     -
    rts

; NGSL_ScriptTextSpeed
; ====================

    NGSL_ScriptTextSpeed:
    jsr     NGSL_GetScriptByte  ; get # of frames between each char
    sta     NGSL_TextSpeed
    rts

; NGSL_GetScriptByte
; ==================

    NGSL_GetScriptByte:
    ldy     #0
    lda     [NGSL_pScript],y
    inc     NGSL_pScript
    bne     +
    inc     NGSL_pScript+1
  + rts

; NGSL_GetDataItemByte
; ====================

    NGSL_GetDataItemByte:
    ldy     #0
    lda     [NGSL_pDataItem],y
    inc     NGSL_pDataItem
    bne     +
    inc     NGSL_pDataItem+1
  + rts

; NGSL_ScriptDelay
; ================

    NGSL_ScriptDelay:
    jsr     NGSL_GetScriptByte  ; get delay amount
  - pha
    lda     #12
 -- pha
    jsr     WaitNMIPass
    pla
    sec
    sbc     #1
    bne     --
    pla
    sec
    sbc     #1
    bne     -
    rts

; NGSL_ScriptGoScript
; ===================

    NGSL_ScriptGoScript:
    jsr     NGSL_GetScriptByte
    tax
    jsr     NGSL_GetScriptByte
    stx     NGSL_pScript
    sta     NGSL_pScript+1
    lda     #mrScriptInit
    sta     MainRoutine
    pla
    pla
    rts

; NGSL_ScriptPrintMsgX
; ====================

    NGSL_ScriptPrintMsgX:
    jsr     NGSL_ScriptPrintMsg
    jmp     NGSL_CursorWaitKey

; NGSL_ScriptMultChoice
; =====================

    NGSL_ScriptMultChoice:
    jsr     NGSL_ScriptPrintMsg ; print the choice text
    jsr     NGSL_GetScriptByte
    sta     MenuItemCount
    lda     #0
    sta     MenuSelect
    lda     #$0D    ; right arrow
    sta     SPR_Tile
    lda     #0
    sta     SPR_Attrib
    lda     #40
    sta     SPR_PosX

    NGSL_MultChoiceMain:
    jsr     NGSL_SetChoiceCursor
    jsr     FlashCursorPal
    jsr     WaitNMIPass
    lda     JoyFirst
    and     #(btnA | btnSTART)
    bne     NGSL_SelectChoice
    lda     JoyFirst
    and     #btnUP
    bne     NGSL_PrevChoice
    lda     JoyFirst
    and     #(btnDOWN | btnSELECT)
    bne     NGSL_NextChoice
    jmp     NGSL_MultChoiceMain

    NGSL_SelectChoice:
    lda     #$F4
    sta     SPR_PosY    ; hide choice cursor
    ldy     MenuSelect
    lda     [NGSL_pScript],y    ; relative offset of choice handler
    jmp     NGSL_ScriptJmp+3    ; go there

    NGSL_PrevChoice:
    lda     MenuSelect
    beq     +
    dec     MenuSelect
    jmp     NGSL_MultChoiceMain
    ; wrap
  + ldy     MenuItemCount
    dey
    sty     MenuSelect
    jmp     NGSL_MultChoiceMain

    NGSL_NextChoice:
    ldy     MenuSelect
    iny
    cpy     MenuItemCount
    beq     +
    sty     MenuSelect
    jmp     NGSL_MultChoiceMain
    ; wrap
  + lda     #0
    sta     MenuSelect
    jmp     NGSL_MultChoiceMain

    NGSL_SetChoiceCursor:
    lda     MenuSelect
    asl
    asl
    asl
    adc     #167
    sta     SPR_PosY
    rts

;NGSL_ScriptSetTitle
;===================

    NGSL_ScriptSetTitle:
    rts

IntroScript:
.incbin "script/introscript.bin"

ZombieScript:
.db SO_SCROFF
.db SO_LOADPIC : .db 2
.db SO_SETPAL
.db SO_SCRON
.db SO_PRINTX : .db 2
.db SO_FADEOUT
.db SO_GOAREA,$FF

SaveScript:
.db SO_SCROFF
.db SO_LOADPIC : .db 3
.db SO_SCRON
.db SO_FADEIN
.db SO_PRINTX : .db 3
.db SO_MULTCHOICE : .db 4 : .db 2
.db 2,3
; save
.db SO_SAVE
; don't save
.db SO_JMPIFSET,7,8
.db SO_SET,7
.db SO_SAVE
.db SO_PLAYSONG,6
.db SO_PRINTX : .db 10
; exit
.db SO_FADEOUT
.db SO_GOAREA,$FF

Boss0IntroScript:
Boss1IntroScript:
.db SO_PLAYSONG,6
.db SO_LOADPIC : .db 4
.db SO_SCRON
.db SO_FADEIN
.db SO_PRINTX : .db 5
.db SO_FADEOUT
.db SO_PLAYSONG,14
.db SO_GOAREA,$FF

; librarian
NPC6Script:
.incbin "script/npc6script.bin"

Item0PickupScript:
Item1PickupScript:
Item2PickupScript:
Item3PickupScript:
Item4PickupScript:
Item5PickupScript:
Item6PickupScript:
Item7PickupScript:
.db SO_LOADPIC : .db 2
.db SO_SCRON
.db SO_FADEIN
.db SO_PRINTX : .db 8
.db SO_FADEOUT
.db SO_GOAREA,$FF

PicTable:
.dw RuinsPic
.dw ScientistPic
.dw ZombiePic
.dw SavePic
.dw BossPic
.dw NPC0Pic
.dw NPC1Pic
.dw NPC2Pic
.dw NPC3Pic
.dw NPC4Pic
.dw NPC5Pic
.dw NPC6Pic
.dw NPC7Pic

RuinsPic:
.db 98   ; CHR page #
.db $0F,$17,$07,$28,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
ScientistPic:
.db 96   ; CHR page #
.db $0F,$11,$17,$28,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
ZombiePic:
.db 100   ; CHR page #
.db $0F,$02,$11,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
SavePic:
.db 102   ; CHR page #
.db $0F,$00,$11,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
BossPic:
.db 104     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC0Pic:
.db 112     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC1Pic:
.db 114     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC2Pic:
.db 116     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC3Pic:
.db 118     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC4Pic:
.db 120     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC5Pic:
.db 122     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC6Pic:
.db 124     ; CHR page #
.db $0F,$01,$11,$31,$0F,$01,$11,$31,$0F,$01,$11,$31 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55
NPC7Pic:
.db 126     ; CHR page #
.db $0F,$00,$1A,$20,$0F,$04,$14,$24,$0F,$08,$18,$28 ; 12-color palette
.db $55,$55,$55,$55 ; attribute data
.db $55,$55,$55,$55

StringTable:
.incsrc "huff/strings.inc"

.end
