.include "anim.h"
.include "game.h"
.include "gbAction.h"
.include "gbLoop.h"
.include "hsge.h"
.include "obj.h"
.include "player.h"
.include "rnme.h"

.codeseg

.public PlayerInit
.public ProjectileInit
.public ManualWarpInit
.public InstantWarpInit
.public ItemInit
.public NPCInit
.public NeoDoorInit
.public BlockingDoorInit

.extrn PlayerStartFall:proc
.extrn GoRoutine:proc
.extrn OBJ_IncY:proc
.extrn OBJ_DecY:proc
.extrn OBJ_DecX:proc
.extrn OBJ_IncX:proc
.extrn ANIM_SetLoop:proc
.extrn GetStatusFlag:proc
.extrn RemoveObject:proc


; PlayerInit
; ==========

    PlayerInit:
    lda     #6
    sta     OBJ_RangeX
    lda     #23
    sta     OBJ_RangeY
    lda     #$38
    sta     OBJ_AccelYFrac
    jmp     PlayerStartFall

; ProjectileInit
; ==============

    ProjectileInit:
    lda     #OE_PROJECTILEMAIN
    sta     OBJ_Action,x
    lda     ProjectileType
    jsr     GoRoutine

.db >(EnergyBulletInit-1), <(EnergyBulletInit-1)
.db >(WaveBulletInit-1), <(WaveBulletInit-1)
.db >(RocketInit-1), <(RocketInit-1)

; RocketInit
; ==========
; Initializes a rocket projectile.

    RocketInit:
    lda     #2
    jsr     OBJ_IncY
; check if ducking
    ldy     OBJ_Action
    cpy     #OE_PLAYERDUCK
    beq     +
    lda     #8
    jsr     OBJ_DecY
;
  + lda     OBJ_State
    and     #$01    ; player's direction
    sta     OBJ_State,x
    lsr
    lda     OBJ_WorldXLo
    bcc     +
    ; fire left
    lda     #14
    jsr     OBJ_DecX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$FE
    sta     OBJ_SpeedX,x
    ; rocket acceleration
    lda     #$E0
    sta     OBJ_AccelXFrac,x
    lda     #$FF
    sta     OBJ_AccelX,x
    bmi     ++  ; branch always
    ; fire right
  + lda     #14
    jsr     OBJ_IncX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$02
    sta     OBJ_SpeedX,x
    ; rocket acceleration
    lda     #$20
    sta     OBJ_AccelXFrac,x
    lda     #$00
    sta     OBJ_AccelX,x
    ;
 ++ lda     #4
    sta     OBJ_RangeX,x
    lda     #8
    sta     OBJ_RangeY,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
    ldy     #LOOP_ROCKET
    lda     #0
    jsr     ANIM_SetLoop
    lda     #SFX_ROCKETLAUNCH
    sta     SFX_Number+1
    rts

; EnergyBulletInit
; ================
; Same deal as the above, mostly. GAH.

    EnergyBulletInit:
    lda     #2
    jsr     OBJ_IncY
;
    ldy     OBJ_Action
    cpy     #OE_PLAYERDUCK
    beq     +
    lda     #8
    jsr     OBJ_DecY
;
  + lda     OBJ_State
    and     #$01    ; player's direction
    sta     OBJ_State,x
    lsr
    lda     OBJ_WorldXLo
    bcc     +
    ; fire left
    lda     #8
    jsr     OBJ_DecX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$FA
    sta     OBJ_SpeedX,x
    bmi     ++  ; branch always
    ; fire right
  + lda     #8
    jsr     OBJ_IncX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$06
    sta     OBJ_SpeedX,x
    ;
 ++ lda     #3
    sta     OBJ_RangeX,x
    lda     #3
    sta     OBJ_RangeY,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
    ldy     #LOOP_ENERGYBULLET
    lda     #0
    jsr     ANIM_SetLoop
    lda     #SFX_ENERGYBULLET
    sta     SFX_Number+1
    rts

; WaveBulletInit
; ==============
; Same same...

    WaveBulletInit:
    lda     #2
    jsr     OBJ_IncY
;
    ldy     OBJ_Action
    cpy     #OE_PLAYERDUCK
    beq     +
    lda     #8
    jsr     OBJ_DecY
;
  + lda     OBJ_State
    and     #$01    ; player's direction
    sta     OBJ_State,x
    lsr
    lda     OBJ_WorldXLo
    bcc     +
    ; fire left
    lda     #8
    jsr     OBJ_DecX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$FC
    sta     OBJ_SpeedX,x
    bmi     ++  ; branch always
    ; fire right
  + lda     #8
    jsr     OBJ_IncX
    ; initial speed
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$04
    sta     OBJ_SpeedX,x
    ;
 ++ lda     #3
    sta     OBJ_RangeX,x
    lda     #3
    sta     OBJ_RangeY,x
    lda     #5
    sta     OBJ_SpeedY,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
    ldy     #LOOP_ENERGYBULLET
    lda     #0
    jsr     ANIM_SetLoop
    lda     #SFX_ENERGYBULLET
    sta     SFX_Number+1
    rts

; InstantWarpInit
; ===============

    InstantWarpInit:
    jsr     ManualWarpInit
    lda     #48
    sta     OBJ_RangeY,x
    lda     #OE_INSTANTWARPMAIN
    sta     OBJ_Action,x
    rts
    
; ManualWarpInit
; ==============

    ManualWarpInit:
    ldy     Index
    lda     [HSGE_pObject],y
    sta     OBJ_Var0,x
    iny
    lda     [HSGE_pObject],y
    sta     OBJ_Var1,x
    iny
    sty     Index
    lda     #2
    sta     OBJ_RangeX,x
    lda     #8
    sta     OBJ_RangeY,x
    lda     #$40
    sta     OBJ_State,x ; invisible
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #OE_IDLE
    sta     OBJ_Action,x
    rts
    
; NPCInit
; =======
; Same as manualwarp, except one extra byte for NPC frame #.

    NPCInit:
    ldy     Index
    lda     [HSGE_pObject],y
    sta     OBJ_Var0,x          ; lo script ptr
    iny
    lda     [HSGE_pObject],y
    sta     OBJ_Var1,x          ; hi script ptr
    iny
    lda     [HSGE_pObject],y    ; NPC frame #
    iny
    sty     Index
    ldy     #LOOP_NPC
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #6
    sta     OBJ_RangeX,x
    lda     #24
    sta     OBJ_RangeY,x
    lda     #OE_NPCMAIN
    sta     OBJ_Action,x
    lda     #8
    jmp     OBJ_IncY

; ItemInit
; ========

    ItemInit:
    ldy     Index
    lda     [HSGE_pObject],y
    sta     OBJ_Var0,x  ; item type
    iny
    sty     Index
    ; check that the item isn't already taken
    ora     #16
    sta     OBJ_Flag,x
    jsr     GetStatusFlag
    beq     +
    ; item already taken, don't load it
    jmp     RemoveObject
    ; item not taken, go ahead and load it
  + ldy     #LOOP_ITEM
    lda     OBJ_Var0,x
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #7
    sta     OBJ_RangeX,x
    lda     #7
    sta     OBJ_RangeY,x
    lda     #OE_ITEMMAIN
    sta     OBJ_Action,x
    lda     #8
    jmp     OBJ_IncY

; NeoDoorInit
; ===========
; Initializes a door that can be only be blasted away with a certain weapon.

    NeoDoorInit:
    lda     #amNoCycling
    sta     ANIM_Method,x
    ldy     #LOOP_NEODOOR
    lda     #0
    jsr     ANIM_SetLoop
    lda     #6
    sta     OBJ_RangeX,x
    lda     #31
    sta     OBJ_RangeY,x
    lda     #OE_NEODOORMAIN
    sta     OBJ_Action,x
    lda     #8
    jmp     OBJ_IncX

; BlockingDoorInit
; ================

    BlockingDoorInit:
    lda     #amNoCycling
    sta     ANIM_Method,x
    ldy     #LOOP_BLOCKINGDOOR
    lda     #0
    jsr     ANIM_SetLoop
    lda     #6
    sta     OBJ_RangeX,x
    lda     #31
    sta     OBJ_RangeY,x
    lda     #OE_BLOCKINGDOORMAIN
    sta     OBJ_Action,x
    lda     #8
    jmp     OBJ_IncX

.end
