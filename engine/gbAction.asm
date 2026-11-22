.include "engine/anim.h"
.include "engine/coll.h"
.include "game.h"
.include "engine/gbAction.h"
.include "engine/obj.h"
.include "sound/rnme.h"
.include "engine/area2d.h"
.include "engine/enemy.h"
.include "common/fade.h"
.include "engine/movement.h"
.include "engine/ngsl.h"
.include "engine/warp.h"

.codeseg

.public ProjectileMain
.public ManualWarpMain
.public InstantWarpMain
.public ItemMain
.public NPCMain
.public NeoDoorMain
.public BlockingDoorMain
.public HealthItemMain
.public WaitAnimEnd
.public DiscardEnemy
.public EnemyMain
.public CheckHealthItemBounce
.public ProgramControl
.public PlayerControl
.public ExplodeProjectile

;-----------------------------------------------------------------------------

.proc ManualWarpMain
  - rts
.endp

;-----------------------------------------------------------------------------

; Automatically initiates the warp if the player is touching the warp spot.

.proc InstantWarpMain
    jsr     TestPlayerCollide
    bne     -
    ; initiate the warp
    lda     #0  ; warptype = unknown ???
    jsr     SetupWarp
    ; remove the warp object, so it isn't triggered again and again
    jmp     RemoveObject
.endp

;-----------------------------------------------------------------------------

.proc ItemMain
    lda     FrameCount
    and     #7
    bne     +
  + jsr     TestPlayerCollide
    bne     -
    ; player picked up the item
    jsr     TestSetObjFlag
    lda     #5
    sta     SFX_Number+1
    ; launch appropriate cutscene
    lda     OBJ_Var0,x  ; item type
    asl
    tay
    lda     ItemPickupScriptPtrs,y
    pha
    lda     ItemPickupScriptPtrs+1,y
    tay
    pla
    jsr     LoadScript
    jsr     RemoveObject    ; remove item
    jmp     PAL_FadeToBlack
.endp

ItemPickupScriptPtrs:
.dw Item0PickupScript
.dw Item1PickupScript
.dw Item2PickupScript
.dw Item3PickupScript
.dw Item4PickupScript
.dw Item5PickupScript
.dw Item6PickupScript
.dw Item7PickupScript

;-----------------------------------------------------------------------------

.proc NPCMain
    jmp     FacePlayer
.endp

;-----------------------------------------------------------------------------

.proc ProjectileMain
    lda     OBJ_State,x
    bpl     +
    ; projectile went offscreen, ditch it
    jmp     RemoveProjectile
  + lda     CollStat
    beq     +
.endp
    ; projectile hit a solid background tile, explode it
.proc ExplodeProjectile
    dec     ProjectileCount
    lda     #$7F        ; HACK!!!
    sta     OBJ_Type,x
    lda     #OE_DISCARDOBJECT
    jsr     SetAnimWaitAction
    lda     #SFX_ROCKETEXPLODE
    sta     SFX_Number+1
    jmp     SetExplodeAnim
  + jmp     @@UpAndDownFlyerMain
  
;-----------------------------------------------------------------------------

; Makes the object move up and down in an accelerated fashion. :]

    @@UpAndDownFlyerMain:
    ; y movement
    lda     OBJ_AccelY,x
    bpl     ++
    ; moving up
    lda     OBJ_SpeedY,x
    cmp     #$FB    ; reached max. speed?
    bne     +
    lda     OBJ_SpeedYFrac,x
    bne     +
    ; turn around
    lda     #$01
    sta     OBJ_AccelY,x
    lda     #$00
    sta     OBJ_AccelYFrac,x
    bpl     +
 ++ ; moving down
    lda     OBJ_SpeedY,x
    cmp     #5      ; reached max. speed?
    bne     +
    ; turn around
    lda     #$FF
    sta     OBJ_AccelY,x
    lda     #$00
    sta     OBJ_AccelYFrac,x
  + rts
.endp

;-----------------------------------------------------------------------------

; Standard enemy discard handler.
; Spawns a health item if this is an odd frame

.proc DiscardEnemy
    lda     FrameCount
    lsr
    bcc     @@NoHealthItemSpawn
    lda     Health
    cmp     MaxHealth       ; only spawn if health isn't already full
    beq     @@NoHealthItemSpawn
    jsr     TestSetObjFlag
    jmp     ObjectToHealthItem
    @@NoHealthItemSpawn:
    jmp     DiscardObject
.endp

;-----------------------------------------------------------------------------

; Transitions to the next state once the animation is done playing.

.proc WaitAnimEnd
    lda     ANIM_Method,x
    cmp     #amNoCycling
    bne     +
    ; set next action as current action
    lda     OBJ_NextAction,x
    sta     OBJ_Action,x
  + rts

;-----------------------------------------------------------------------------

; Standard enemy handler.

  - rts
.endp
.proc EnemyMain
    lda     OBJ_State,x
    bmi     -           ; don't update if offscreen
    jsr     CheckPlayerHit
    jmp     CheckEnemyHit
.endp
    
;-----------------------------------------------------------------------------

.proc HealthItemMain
    jsr     CheckHealthItemBounce
    jsr     CheckHealthItemAlive
    jmp     CheckHealthItemPickup
.endp
    
.proc CheckHealthItemBounce
    lda     CollStat
    and     #COLL_DOWN
    beq     -
; item hit floor, see if it should bounce up again
    lda     OBJ_SpeedYFrac,x
    sec
    sbc     #$C0
    tay
    lda     OBJ_SpeedY,x
    sbc     #0
    bmi     +
; bounce it
    sta     OBJ_SpeedY,x
    tya
    sta     OBJ_SpeedYFrac,x
    jsr     InvertYSpeed
    sta     OBJ_SpeedY,x
    tya
    sta     OBJ_SpeedYFrac,x
    lda     #SFX_METAL
    sta     SFX_Number+1
    rts
; stop bouncing
  + lda     #0
    sta     OBJ_SpeedY,x
    sta     OBJ_SpeedYFrac,x
  - rts
.endp
    
.proc CheckHealthItemAlive
    lda     OBJ_Health,x
    beq     +
    dec     OBJ_Health,x
    bne     -
; make it blink for $50 frames, then disappear
    lda     #$50
    sta     OBJ_Blink,x
  + lda     OBJ_Blink,x
    bne     -
    jmp     RemoveObject
    
    CheckHealthItemPickup:
    jsr     TestPlayerCollide
    bne     -
; player picks up item
    lda     Health
    clc
    adc     #1
    bcs     +
    cmp     MaxHealth
    bcc     ++
  + lda     MaxHealth
 ++ sta     Health
    txa
    pha
    jsr     SetHealthPal    ; update health meter palette
    pla
    tax
    lda     #5
    sta     SFX_Number+1
    jmp     RemoveObject
.endp

;-----------------------------------------------------------------------------

; PlayerControl
; =============
; Gives player control again.

.proc PlayerControl
    lda     $7FFE       ; !!!
    sta     OBJ_Action  ; restore player's action
    rts
.endp

; ProgramControl
; ==============
; Prohibits player from interacting/interfering.

.proc ProgramControl
    lda     OBJ_Action
    sta     $7FFE       ; !!! store player's current action
    ldy     #0
    lda     #OE_IDLE
    sta     OBJ_Action,y
    rts
.endp

;-----------------------------------------------------------------------------

.proc NeoDoorMain
    rts
.endp

;-----------------------------------------------------------------------------

.proc BlockingDoorMain
    lda     OBJ_State,x
    bpl     +
    ; do nothing if door is not onscreen
    rts
  + jsr     BlockPlayer
    jsr     TestProjectileCollide
    bne     +
    jsr     ExplodeProjectile2
  + lda     RoomFlags
    beq     +
; close the door
    lda     #amForward
    sta     ANIM_Method,x
    rts
; open the door
  + lda     #amReverse
    sta     ANIM_Method,x
    lda     #15
    jsr     ANIM_SetCel
    lda     #OE_DISCARDOBJECT
    jmp     SetAnimWaitAction
.endp

; BlockPlayer
; ===========
; Stops player from walking through current object.
; In: X = object slot

.proc BlockPlayer
    jsr     TestPlayerCollide
    beq     +
; object isn't touching player, so exit
    rts
; stop player from walking through object
  + lda     OBJ_ScreenX
    cmp     OBJ_ScreenX,x
    bcc     +
    ; object is left of player
    lda     OBJ_WorldXFrac
    clc
    adc     #$80
    sta     OBJ_WorldXFrac
    lda     OBJ_WorldXLo
    adc     #$01
    sta     OBJ_WorldXLo
    rts
  + ; object is right of player
    lda     OBJ_WorldXFrac
    sec
    sbc     #$80
    sta     OBJ_WorldXFrac
    lda     OBJ_WorldXLo
    sbc     #$01
    sta     OBJ_WorldXLo
    rts
.endp

.end
