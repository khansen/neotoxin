.include "chr/chr.h"
.include "game.h"
.include "engine/gbAction.h"
.include "engine/hsge.h"
.include "common/mmc3.h"
.include "common/nes.h"
.include "engine/ngsl.h"
.include "engine/obj.h"
.include "engine/anim.h"
.include "engine/area2d.h"
.include "engine/bgcollision.h"
.include "game/demomode.h"
.include "engine/enemy.h"
.include "common/fade.h"
.include "game/flags.h"
.include "common/math.h"
.include "engine/objcollision.h"
.include "common/palette.h"
.include "common/ppu.h"
.include "engine/renderer.h"
.include "engine/scroller.h"
.include "screens/statusscreen.h"
.include "engine/warp.h"
.include "common/nmi.h"
.include "game/maincycle.h"
.include "common/joypad.h"
.include "common/timer.h"
.include "engine/player.h"

.dataseg zeropage

RoomFlags           .byte

.codeseg

.public RoomFlags
.public SetTimer
.public LoadScript
.public SetHealthPal
.public Area2DInit
.public Area2DMain
.public WaitTimer

; SharedAreaInit
; ==============
; Init stuff that needs to be done equally for both 2D and 3D areas.

.proc SharedAreaInit
    jsr     ScreenOff
    jsr     ClearDisplay
    jsr     DestroyAllObjects
; set CHR page array
    lda     ah_AreaCHR
    sta     SelectedCHR
    lda     ah_AreaCHR+1
    sta     SelectedCHR+1
; load palette
    lda     ah_pAreaPalette
    ldy     ah_pAreaPalette+1
    jmp     PAL_LoadPalette
.endp

; Area2DInit
; ==========
; Initialize the 2D Area.

.proc Area2DInit
;;;;
    lda     #2
    jsr     SetStatusFlag
;;;;
    jsr     SharedAreaInit
    jsr     Load2DArea
; initialize various variables
    lda     ZPCtrl0
    and     #%11011100      ; nametable addr = $2000
    ora     #%00100000      ; sprite size = 8x16
    sta     ZPCtrl0
    lda     #H_MIRROR
    sta     MMC3_MIRROR_REG
; initialize OBJ 0 (player)
    lda     AreaStartX
    sta     ObjPageX
    ldy     AreaStartY
    sty     ObjPageY
    jsr     OBJ_CalcMapOfs
    sta     ObjMapOfs
    ldx     #0  ; object 0
    ldy     #0  ; type 0
    lda     PlayerStart  ; position
    jsr     LoadObject
;; direction
    lda     $7FFF
    sta     OBJ_State
;;
    lda     OBJ_WorldYLo
    ora     #8
    sta     OBJ_WorldYLo
    inc     OBJ_SpeedY  ; =1
; initalize scroll engine and BG display
    lda     #1
    sta     HSGE_RoomCol
    lda     #0
    sta     HSGE_ScreenTable
    sta     HSGE_RoomRow
    sta     HSGE_RoomOfs
    sta     HSGE_ScreenRow
    sta     HSGE_WorldViewX
    sta     HSGE_WorldViewY
    sta     HSGE_ScrollY
    sta     HSGE_QueueSize
    sta     HSGE_ScrollQueue
    sta     HSGE_ScrollQueue+1
    sta     ObjLoadQueueXSize
    sta     ObjLoadQueueYSize
; render the whole screen
    lda     AreaStartX
    sta     HSGE_WorldViewX+1
    ldy     AreaStartY
    sty     HSGE_WorldViewY+1
    jsr     OBJ_CalcMapOfs
    sta     HSGE_MapOfs
    dec     HSGE_MapOfs
    jsr     HSGE_RenderScreen
; load initial objects
    ; (X,Y)
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_LoadObjects
    ; (X-1,Y)
    lda     HSGE_WorldViewX+1
    sec
    sbc     #1
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_LoadObjects
    ; (X+1,Y)
    lda     HSGE_WorldViewX+1
    clc
    adc     #1
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_LoadObjects
    ; (X+2,Y)
    lda     HSGE_WorldViewX+1
    clc
    adc     #2
    ldy     HSGE_WorldViewY+1
    jsr     HSGE_LoadObjects
    ; (X,Y-1)
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_LoadObjects
    ; (X-1,Y-1)
    lda     HSGE_WorldViewX+1
    sec
    sbc     #1
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_LoadObjects
    ; (X+1,Y-1)
    lda     HSGE_WorldViewX+1
    clc
    adc     #1
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_LoadObjects
    ; (X+2,Y-1)
    lda     HSGE_WorldViewX+1
    clc
    adc     #2
    ldy     HSGE_WorldViewY+1
    dey
    jsr     HSGE_LoadObjects
    ; (X,Y+1)
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_LoadObjects
    ; (X-1,Y+1)
    lda     HSGE_WorldViewX+1
    sec
    sbc     #1
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_LoadObjects
    ; (X+1,Y+1)
    lda     HSGE_WorldViewX+1
    clc
    adc     #1
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_LoadObjects
    ; (X+2,Y+1)
    lda     HSGE_WorldViewX+1
    clc
    adc     #2
    ldy     HSGE_WorldViewY+1
    iny
    jsr     HSGE_LoadObjects
    ; (X,Y+2)
    lda     HSGE_WorldViewX+1
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_LoadObjects
    ; (X-1,Y+2)
    lda     HSGE_WorldViewX+1
    sec
    sbc     #1
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_LoadObjects
    ; (X+1,Y+2)
    lda     HSGE_WorldViewX+1
    clc
    adc     #1
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_LoadObjects
    ; (X+2,Y+2)
    lda     HSGE_WorldViewX+1
    clc
    adc     #2
    ldy     HSGE_WorldViewY+1
    iny
    iny
    jsr     HSGE_LoadObjects
; scroll display according to player's starting position
    lda     #0  ; 256 pixels, just to be sure
  - pha
    ldx     #0
    jsr     OBJ_CoordsToScreen
    jsr     CheckScroll
    jsr     HSGE_CheckScreenWrite
    jsr     CheckPPUWrite
    pla
    sec
    sbc     #1
    bne     -
.ifdef DEMOREC
; prepare to record game demo
    lda     #>DEMO_BUFFER
    sta     pDemo+1
    ldy     #0
    sty     pDemo   ; store demo in WRAM at DEMO_BUFFER
    sty     OldStat
    iny     ; =1
    sty     JoyCount
.endif  ; DEMOREC

    lda     #0
    sta     ProjectileCount
    jsr     SetHealthPal
    lda     #CHR_STATUS
    sta     SelectedCHR+3
    lda     #mrArea2DMain
    ldy     DemoMode
    beq     +
    lda     #mrPlayDemo
  + sta     MainRoutine
    jsr     Area2DMain   ; just so objects are drawn during fade-in
    lda     #0
    sta     IRQRoutine
    lda     #231
    sta     IRQCount
    jsr     ScreenOn
    jmp     PAL_FadeFromBlack
.endp

; Area2DMain
; ==========
; The game engine main loop.

    Area2DMain:
.ifdef DEMOREC
    jsr     RecordDemo
.endif
    jsr     UpdateObjects
    jsr     ShowHealth
    lda     OBJ_Action
    cmp     #OE_IDLE
    beq     +
    jsr     CheckScroll
  + jsr     HSGE_CheckScreenWrite
    lda     HSGE_WorldViewX
    sta     ScrollX
    lda     HSGE_ScrollY
    sta     ScrollY
    jsr     LoadObjectsFromQueue
    jsr     UpdateClock
    jsr     CheckWeaponSwitch
    jmp     CheckPause

; CheckWeaponSwitch
; =================

.proc CheckWeaponSwitch
    lda     JoyFirst
    and     #btnSELECT
    beq     +
    ; switch weapon
    inc     ProjectileType
    lda     ProjectileType
    cmp     #3
    bcc     +
    lda     #0
    sta     ProjectileType
  + rts
.endp

; UpdateObjects
; =============
; Moves & draws all objects, checks for collisions, calls object handlers.

.proc UpdateObjects
    jsr     DestroyAllSprites
    lda     SpriteBase
    sta     SpriteIndex
    ldx     #MAX_OBJECTS-1
    @@UpdateOneObject:
    lda     OBJ_Type,x
    bmi     @@NextObject  ; skip the whole thing if object is inactive
    lda     #0
    sta     CollObjCount
    jsr     MoveObject
    jsr     OBJ_CoordsToScreen
    bmi     +           ; no crash detection if object is offscreen
    jsr     CheckObjColl
  + jsr     OBJ_PerformAction
    lda     OBJ_Blink,x
    beq     +           ; skip if object not blinking
    lda     OBJ_State,x
    eor     #$40        ; toggle visibility
    dec     OBJ_Blink,x
    bne     ++
    and     #$BF        ; make sure object is visible
 ++ sta     OBJ_State,x
  + jsr     ANIM_GoMethod
    lda     OBJ_State,x
    cmp     #$40
    bcs     @@NextObject  ; don't draw if offscreen or invisible
    jsr     ANIM_DrawCel
    @@NextObject:
    dex
    bpl     @@UpdateOneObject
    lda     SpriteBase
    clc
    adc     #17*4
    sta     SpriteBase
    rts
.endp

; ShowHealth
; ==========

.proc ShowHealth
    ldx     SpriteIndex
    lda     #15
    sta     SPR_PosY,x
    lda     Health
    and     #7
    asl
    ora     #$41
    sta     SPR_Tile,x
    lda     #16
    sta     SPR_PosX,x
    lda     #1
    sta     SPR_Attrib,x
    txa
    clc
    adc     #15*4
    sta     SpriteIndex
    rts
.endp

; SetHealthPal
; ============

.proc SetHealthPal
    ldx     PPUStrIndex
    lda     #$3F
    sta     PPUString,x
    inx
    lda     #$15
    sta     PPUString,x
    inx
    lda     #$02
    sta     PPUString,x
    inx
    lda     Health
    lsr
    lsr
    and     #6
    tay
    lda     HealthPals,y
    sta     PPUString,x
    sta     RAMPalette+21
    inx
    lda     HealthPals+1,y
    sta     PPUString,x
    sta     RAMPalette+22
    inx
    jmp     EndPPUString
.endp
    
HealthPals:
.db $10,$16 ; 0-7
.db $16,$28 ; 8-15
.db $28,$2A ; 16-23
.db $2A,$0F ; 24

; CheckScroll
; ===========
; Checks if it's necessary to scroll the display, based on player's position.

.proc CheckScroll
; check X direction
    lda     OBJ_State
    lsr                 ; CF = player's direction
    lda     OBJ_ScreenX
    bcc     +           ; branch if facing the RIGHT
    jsr     XSIGN
  + cmp     #SCROLL_TRESHOLD
    beq     @@CheckScrollY
    bcs     @@DoScrollX
    ;
    lda     OBJ_State
    lsr
    bcs     +
    jsr     HSGE_ScrollLeft
    jmp     @@CheckScrollY
  + jsr     HSGE_ScrollRight
    jmp     @@CheckScrollY
    @@DoScrollX:
    sbc     #SCROLL_TRESHOLD
    lsr
    lsr
    lsr
    lsr
    clc
    adc     #1
    cmp     #MAX_SCROLLSPEED
    bcc     +
    lda     #MAX_SCROLLSPEED    ; max. pixels to scroll per frame
  + sta     Count           ; # of pixels to scroll
    lda     OBJ_State
    lsr
    bcs     @@DoScrollLeft
  - jsr     HSGE_ScrollRight
    bcs     @@CheckScrollY    ; stop if can't scroll any further
    dec     Count           ; scrolled desired amount?
    bne     -               ; if not, attempt to scroll another pixel
    beq     @@CheckScrollY
    @@DoScrollLeft:
    jsr     HSGE_ScrollLeft
    bcs     @@CheckScrollY    ; stop if can't scroll any further
    dec     Count           ; scrolled desired amount?
    bne     @@DoScrollLeft    ; if not, attempt to scroll another pixel
    @@CheckScrollY:
; check Y direction
    lda     #4              ; max. 4 pixels per frame
    sta     Count
    lda     OBJ_ScreenY
    sta     Temp
  - lda     Temp
    cmp     #110
    bcc     +
    cmp     #130
    bcc     @@NoScrollY
    jsr     HSGE_ScrollDown
    dec     Temp
    jmp     ++
  + jsr     HSGE_ScrollUp
    inc     Temp
 ++ dec     Count
    bne     -
    @@NoScrollY:
    rts
.endp

; WaitTimer
; =========
; Waits for Timer to hit zero, then updates MainRoutine.
; Basically just delays the program for a certain amount of time.

.proc WaitTimer
    lda     Timer
    bne     +
    lda     NextRoutine
    sta     MainRoutine
  + rts
.endp

; SetTimer
; ========
; In: A = # of time units to delay
;     X = next routine to execute after delay

.proc SetTimer
    sta     Timer
    stx     NextRoutine
    lda     #mrWaitTimer
    sta     MainRoutine
    rts
.endp

; LoadScript
; ==========

.proc LoadScript
    sta     NGSL_pScript
    sty     NGSL_pScript+1
    lda     #mrScriptInit
    sta     MainRoutine
    rts
.endp

.end
