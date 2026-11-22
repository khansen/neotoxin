.include "game.h"
.include "common/nes.h"
.include "sound/rnme.h"
.include "screens/entername.h"
.include "common/fade.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "game/savegame.h"
.include "screens/screendata.h"
.include "screens/selectgame.h"
.include "engine/warp.h"
.include "common/mmc3.h"

.codeseg

.public SelectGameInit
.public SelectGameMain
.public GameMenuMain

; SelectGameInit
; ==============

.proc SelectGameInit
    jsr     ScreenOff
    jsr     ClearDisplay
    lda     #0
    sta     ScrollX
    sta     ScrollY
    lda     ZPCtrl0
    and     #$FC        ; select nametable 0
    sta     ZPCtrl0
; load Select Game Interface
    lda     #<SelectGameData
    ldy     #>SelectGameData
    jsr     WriteROMPPUString
    lda     #<StatusScreenPal
    ldy     #>StatusScreenPal
    jsr     PAL_LoadPalette
    lda     #<StatusScreenCHR
    ldy     #>StatusScreenCHR
    jsr     LoadCHR
; set up cursor
    lda     #$03    ; square
    sta     SPR_Tile
    lda     #48
    sta     SPR_PosX
    lda     #0
    sta     SPR_Attrib
    jsr     SetSlotCursor
; start "game select" music
    lda     #15
    sta     RNME_LoadTune
    inc     MainRoutine
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack
.endp

; SelectGameMain
; ==============

.proc SelectGameMain
    jsr     FlashCursorPal
    lda     #(btnSTART + btnA)
    and     JoyFirst
    beq     @@NoSlotSelect
; select current slot
    jsr     SetSavePtr
    ldy     #60
    lda     [pData],y
    iny
    ora     [pData],y
    bne     @@EnterGameMenu
; start a new game in current slot
    lda     #mrStartNewGame
    sta     NextRoutine
    lda     #mrEnterNameInit
    sta     MainRoutine
    lda     #5
    sta     SFX_Number+1
    jmp     PAL_FadeToBlack

    @@EnterGameMenu:
    lda     #3
    sta     SFX_Number+1
    lda     #0
    sta     MenuSelect
    lda     #$0B    ; round dot
    sta     SPR_Tile
    lda     #104
    sta     SPR_PosX
    lda     #0
    sta     SPR_Attrib
    lda     #mrGameMenuMain
    sta     MainRoutine
    jmp     SetMenuCursor

    @@NoSlotSelect:
    lda     #(btnUP + btnDOWN + btnSELECT)
    and     JoyFirst
    beq     @@NoSlotChange
    ldy     #3
    sty     SFX_Number+1
    and     #(btnDOWN + btnSELECT)
    bne     @@NextSaveSlot
; move to previous slot
    dec     SaveSlot
    jmp     SetSlotCursor

    @@NoSlotChange:
    lda     #btnB
    and     JoyFirst
    beq     +
; exit from game select
    jsr     PAL_FadeToBlack
    lda     #mrTitleInit
    sta     MainRoutine
  + rts

    @@NextSaveSlot:
    inc     SaveSlot
.endp

.proc SetSlotCursor
    lda     SaveSlot
    and     #$07
    sta     SaveSlot
    asl
    asl
    asl
    sta     Temp
    asl
    adc     Temp
    adc     #31
    sta     SPR_PosY

    ldx     PPUStrIndex
    lda     #$20
    sta     PPUString,x
    inx
    lda     #$EE
    sta     PPUString,x
    inx
    lda     #10
    sta     Count
    sta     PPUString,x
    inx
    jsr     SetSavePtr
    ldy     #60
    lda     [pData],y
    iny
    ora     [pData],y
    bne     +
    lda     #<NewGameString
    sta     pData
    lda     #>NewGameString
    sta     pData+1
    ldy     #0
    beq     @@CopyNameString
  + ldy     #49
    @@CopyNameString:
    lda     [pData],y
    iny
    sta     PPUString,x
    inx
    dec     Count
    bne     @@CopyNameString
    jmp     EndPPUString
.endp

; GameMenuMain
; ============

.proc GameMenuMain
    jsr     FlashCursorPal
    lda     #btnB
    and     JoyFirst
    beq     +
; exit menu
    @@ExitGameMenu:
    lda     #3
    sta     SFX_Number+1
    lda     #$03    ; square
    sta     SPR_Tile
    lda     #48
    sta     SPR_PosX
    lda     #0
    sta     SPR_Attrib
    lda     #mrSelectGameMain
    sta     MainRoutine
    jmp     SetSlotCursor

  + lda     #(btnA + btnSTART)
    and     JoyFirst
    beq     @@NoMenuConfirm
; perform selected command
    ldy     #5
    sty     SFX_Number+1
    ldy     MenuSelect
    beq     @@LoadSelectedSlot
    dey
    beq     @@CopySelectedSlot
    dey
    beq     @@DeleteSelectedSlot
; change name
    lda     #mrPerformNameChange
    sta     NextRoutine
    lda     #mrEnterNameInit
    sta     MainRoutine
    jmp     PAL_FadeToBlack

    @@LoadSelectedSlot:
    jsr     LoadSaveGame
    lda     #mrExecWarp
    sta     MainRoutine
    jmp     PAL_FadeToBlack

    @@CopySelectedSlot:
    rts

    @@DeleteSelectedSlot:
    jsr     SetSavePtr
    ldy     #63
    lda     #0
  - sta     [pData],y
    dey
    bpl     -
    jmp     @@ExitGameMenu

    @@NoMenuConfirm:
    lda     #(btnUP + btnDOWN + btnSELECT)
    and     JoyFirst
    bne     +
    rts
  + ldy     #3
    sty     SFX_Number+1
    and     #(btnDOWN + btnSELECT)
    bne     @@NextMenuItem
; previous menu item
    dec     MenuSelect
    jmp     SetMenuCursor
    @@NextMenuItem:
    inc     MenuSelect

    SetMenuCursor:
    lda     MenuSelect
    and     #$03
    sta     MenuSelect
    asl
    asl
    asl
    adc     #167
    sta     SPR_PosY
    rts
.endp

.end
