.include "engine/anim.h"
.include "game.h"
.include "engine/gbAction.h"
.include "engine/gbLoop.h"
.include "engine/gbObj.h"
.include "engine/hsge.h"
.include "common/nes.h"
.include "engine/obj.h"
.include "game/flags.h"
.include "common/math.h"
.include "engine/renderer.h"
.include "engine/warp.h"

.codeseg

.public DiscardObject
.public ToggleDirection
.public FaceLeft
.public FaceRight
.public ResetMotion
.public FacePlayer
.public SpawnObject
.public RemoveObject
.public OBJ_CalcMapOfs
.public FindObjSlot
.public GoCodePtr
.public OBJ_IncY
.public OBJ_DecY
.public OBJ_DecX
.public OBJ_IncX
.public TestSetObjFlag
.public RemoveProjectile
.public ObjectToHealthItem
.public OBJ_CoordsToScreen
.public DestroyAllSprites
.public DestroyAllObjects
.public OBJ_PerformAction

;-----------------------------[ Sprite stuff ]--------------------------------

; Destroy all sprites
; ===================

.proc DestroyAllSprites
    ldx     #$00
    lda     #$F4
  - sta     SPR_PosY,x     ; Set Y coord to below visible screen
    inx
    inx
    inx
    inx
    bne     -
    rts
.endp

;-----------------------------------------------------------------------------

; OBJ_CoordsToScreen
; ==================
; Convert from world coordinates to screen coordinates.

.proc OBJ_CoordsToScreen
    lda     OBJ_WorldYLo,x
    sec
    sbc     HSGE_WorldViewY
    sta     OBJ_ScreenY,x
    lda     OBJ_WorldYHi,x
    sbc     HSGE_WorldViewY+1
    sta     Temp
    lda     OBJ_WorldXLo,x
    sec
    sbc     HSGE_WorldViewX
    sta     OBJ_ScreenX,x
    lda     OBJ_WorldXHi,x
    sbc     HSGE_WorldViewX+1
    ora     Temp
    beq     +
    lda     OBJ_State,x
    ora     #$80            ; set offscreen flag
    sta     OBJ_State,x
    rts
  + lda     OBJ_State,x
    and     #$7F            ; clear offscreen flag
    sta     OBJ_State,x
    rts
.endp

;-----------------------------------------------------------------------------

; OBJ_PerformAction
; =================

.proc OBJ_PerformAction
    lda     OBJ_Action,x
    asl
    tay
    lda     [ah_pActionPtrTable],y
    sta     pCode
    iny
    lda     [ah_pActionPtrTable],y
    sta     pCode+1
.endp
.proc GoCodePtr
    jmp     [pCode]
.endp

;-----------------------------------------------------------------------------

; Add amount to object's X position.
; In: A = amount to add

.proc OBJ_IncX
    clc
    adc     OBJ_WorldXLo,x
    sta     OBJ_WorldXLo,x
    bcc     +
    inc     OBJ_WorldXHi,x
    inc     OBJ_MapOfs,x
  + rts
.endp

; Subtract amount from object's X position.
; In: A = amount to subtract

.proc OBJ_DecX
    jsr     XSIGN
    adc     OBJ_WorldXLo,x
    sta     OBJ_WorldXLo,x
    bcs     +
    dec     OBJ_WorldXHi,x
    dec     OBJ_MapOfs,x
  + rts
.endp

; Add amount to object's Y position.
; In: A = amount to add

.proc OBJ_IncY
    clc
    adc     OBJ_WorldYLo,x
    sta     OBJ_WorldYLo,x
    bcc     +
    inc     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    clc
    adc     MapWidth
    sta     OBJ_MapOfs,x
  + rts
.endp

; Subtract amount from object's Y position.
; In: A = amount to subtract

.proc OBJ_DecY
    jsr     XSIGN
    adc     OBJ_WorldYLo,x
    sta     OBJ_WorldYLo,x
    bcs     +
    dec     OBJ_WorldYHi,x
    lda     OBJ_MapOfs,x
    sec
    sbc     MapWidth
    sta     OBJ_MapOfs,x
  + rts
.endp

;-----------------------------------------------------------------------------

; OBJ_CalcMapOfs
; ==============
; A = map X page
; Y = map Y page

.proc OBJ_CalcMapOfs
    clc
  - dey
    bmi     +
    adc     MapWidth
    bcc     -           ; branch always
  + rts
.endp

;-----------------------------------------------------------------------------

; FindObjSlot
; ===========
; Find 1st available object slot.

.proc FindObjSlot
    pha     ; don't want to destroy Acc
    ldx     #23
  - lda     OBJ_Type,x
    bmi     +   ; bit 7 set means slot is available
    dex     ; try next slot
    bne     -
    ; no slots left!!! CRISIS
  + pla
    rts
.endp

;-----------------------------------------------------------------------------

.proc DestroyAllObjects
    ldx     #23
  - jsr     KillObject
    dex
    bpl     -
    inx
    stx     ObjCount    ; = 0
  - rts
.endp

;-----------------------------------------------------------------------------

; If object flag is non-zero, set it.

.proc TestSetObjFlag
    lda     OBJ_Flag,x
    beq     -
    jmp     SetStatusFlag
.endp

;-----------------------------------------------------------------------------

.proc RemoveProjectile
    dec     ProjectileCount
    bpl     RemoveObject    ; branch always, hopefully
.endp
.proc DiscardObject
    jsr     TestSetObjFlag
.endp
.proc RemoveObject
    dec     ObjCount
.endp
.proc KillObject
    lda     #$80
    sta     OBJ_Type,x  ; invalid
    sta     OBJ_State,x ; offscreen
    lda     #0
    sta     OBJ_Blink,x
    sta     OBJ_Flag,x
    sta     OBJ_WorldXLo,x
    sta     OBJ_WorldXHi,x
    sta     OBJ_WorldXFrac,x
    sta     OBJ_WorldYLo,x
    sta     OBJ_WorldYHi,x
    sta     OBJ_WorldYFrac,x
    sta     OBJ_ScreenX,x
    sta     OBJ_ScreenY,x
.endp
.proc ResetMotion
    sta     OBJ_SpeedX,x
    sta     OBJ_SpeedY,x
    sta     OBJ_SpeedXFrac,x
    sta     OBJ_SpeedYFrac,x
    sta     OBJ_AccelX,x
    sta     OBJ_AccelY,x
    sta     OBJ_AccelXFrac,x
    sta     OBJ_AccelYFrac,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc ToggleDirection
    lda     OBJ_State,x
    eor     #1
    sta     OBJ_State,x
    rts
.endp
    
.proc FaceLeft
    lda     OBJ_State,x
    ora     #1
    sta     OBJ_State,x
    rts
.endp

.proc FaceRight
    lda     OBJ_State,x
    and     #$FE
    sta     OBJ_State,x
    rts
.endp

.proc FacePlayer
    lda     OBJ_ScreenX,x
    cmp     OBJ_ScreenX
    bcc     +
    jmp     FaceLeft
  + jmp     FaceRight
.endp
  
;-----------------------------------------------------------------------------

; CopyObjCoords
; =============
; Copies coordinates from object at index Y to object at index X.

.proc CopyObjCoords
    lda     OBJ_MapOfs,y
    sta     OBJ_MapOfs,x
    lda     OBJ_WorldXHi,y
    sta     OBJ_WorldXHi,x
    lda     OBJ_WorldYHi,y
    sta     OBJ_WorldYHi,x
    lda     OBJ_WorldXLo,y
    sta     OBJ_WorldXLo,x
    lda     OBJ_WorldYLo,y
    sta     OBJ_WorldYLo,x
    rts
.endp

;-----------------------------------------------------------------------------

; SpawnObject
; ===========
; An object spawns a new object.
; The new object is placed at the position of the spawning object.
;
; In: Y = object type to spawn
;     X = spawning object

.proc SpawnObject
    txa
    pha     ; save spawning object
    jsr     FindObjSlot
    inc     ObjCount
    tya
    sta     OBJ_Type,x
    pla     ; get spawning object again
    pha
    tay
    jsr     CopyObjCoords
    lda     OBJ_Type,x
    jsr     ExecObjConstr
    pla
    tax     ; restore
    rts
.endp

;-----------------------------------------------------------------------------

; ObjectToHealthItem
; ==================
; Turns an object into a health item.
; In: X = object index

.proc ObjectToHealthItem
    lda     #OT_ITEM
    sta     OBJ_Type,x
    lda     #0  ; item type
    sta     OBJ_Var0,x
    lda     #OE_HEALTHITEMMAIN
    sta     OBJ_Action,x
    lda     #$2C
    sta     OBJ_AccelYFrac,x
    lda     #$FE
    sta     OBJ_SpeedY,x
    lda     #7
    sta     OBJ_RangeX,x
    sta     OBJ_RangeY,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #$FF            ; # of frames till item fades away
    sta     OBJ_Health,x
    lda     #0
    sta     OBJ_State,x
    ldy     #LOOP_HEALTHITEM
    lda     #0
    jmp     ANIM_SetLoop
.endp

.end
