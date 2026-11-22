.include "anim.h"
.include "game.h"
.include "gbAction.h"
.include "gbLoop.h"
.include "gbObj.h"
.include "obj.h"
.include "player.h"
.include "rnme.h"

.codeseg

.public RND
.public TestProjectileCollide
.public CheckPlayerHit
.public CheckEnemyHit
.public IsPlayerHitAndWoundable
.public HurtPlayer
.public SetAnimWaitAction
.public SetExplodeAnim
.public LoadBlockingDoor
.public TestPlayerCollide
.public ExplodeProjectile2
.public LoadObjectsFromQueue

.extrn HSGE_LoadObjects:proc
.extrn EnemyDamageTable:label
.extrn ProjectileDamageTable:label
.extrn ExpTable:label
.extrn AdjustExpGain:proc
.extrn AddExpPoints:proc
.extrn CheckLevelAdvance:proc
.extrn CheckIfCollided:proc
.extrn ExplodeProjectile:proc
.extrn SetHealthPal:proc
.extrn PlayerStandUp:proc
.extrn ANIM_SetLoop:proc
.extrn ResetMotion:proc
.extrn FindObjSlot:proc
.extrn LoadObject:proc

; LoadObjectsFromQueue
; ====================

    LoadObjectsFromQueue:
    lda     ObjLoadQueueXSize
    beq     ++
    lda     ObjLoadQueueX
    ldy     ObjLoadQueueX+4
    jsr     HSGE_LoadObjects
    ldy     #0
    dec     ObjLoadQueueXSize
    beq     +
  - lda     ObjLoadQueueX+1,y
    sta     ObjLoadQueueX,y
    lda     ObjLoadQueueX+5,y
    sta     ObjLoadQueueX+4,y
    iny
    cpy     ObjLoadQueueXSize
    bcc     -
  + rts
 ++ lda     ObjLoadQueueYSize
    beq     +
    lda     ObjLoadQueueY
    ldy     ObjLoadQueueY+4
    jsr     HSGE_LoadObjects
    ldy     #0
    dec     ObjLoadQueueYSize
    beq     +
  - lda     ObjLoadQueueY+1,y
    sta     ObjLoadQueueY,y
    lda     ObjLoadQueueY+5,y
    sta     ObjLoadQueueY+4,y
    iny
    cpy     ObjLoadQueueYSize
    bcc     -
  + rts
    
; RND
; ===
; "Random" number generator. (BAD!)

    RND:
    lda     #39
    adc     FrameCount
    eor     FrameCount
    adc     Random
    inc     Random
    sbc     FrameCount
    eor     Random
    rts
    
; SetAnimWaitAction
; =================

    SetAnimWaitAction:
    sta     OBJ_NextAction,x
    lda     #OE_WAITANIMEND
    sta     OBJ_Action,x
    rts

; IsPlayerHitAndWoundable
; =======================
; Returns: CF = 1 if the current object collided with player and player can be wounded

    IsPlayerHitAndWoundable:
    lda     OBJ_Blink
    bne     +
    jsr     TestPlayerCollide
    bne     +
; player hit, make sure he's not already dead
    lda     OBJ_Action
    cmp     #OE_PLAYERDEAD
    beq     +
    sec     ; player can be hurt
    rts
  + clc     ; player can't be hurt
  - rts

; CheckPlayerHit
; ==============
; Checks if the player has been hit by an enemy.
; If so, the player is damaged appropriately.

    CheckPlayerHit:
    jsr     IsPlayerHitAndWoundable
    bcc     -
; figure out how much damage to inflict on player
    ldy     OBJ_Type,x
    lda     EnemyDamageTable-8,y
    tay
    lda     #0
    sta     Count
    lda     HealthFrac
  - sec
    sbc     #INITIAL_DEFENSE
    beq     ++
    bcs     +
 ++ clc
    adc     Defense
    inc     Count
  + dey
    bne     -
    sta     HealthFrac
    lda     Count
    jsr     HurtPlayer
  - rts

; CheckEnemyHit
; =============
; Checks if enemy has been hit by projectile.
; If so, the enemy is damaged appropriately.

    CheckEnemyHit:
    jsr     TestProjectileCollide
    bne     -
; enemy hit by projectile
    jsr     ExplodeProjectile2
; damage enemy. amount depends on weapon type
    ldy     ProjectileType
    lda     OBJ_Health,x
    sec
    sbc     ProjectileDamageTable,y
    bpl     +
    lda     #0
  + sta     OBJ_Health,x
    beq     EnemyDead
    lda     #30     ; blink for 30 frames (half a second)
    sta     OBJ_Blink,x
    lda     #SFX_ENEMYHIT
    sta     SFX_Number+1
    rts
    EnemyDead:
; calc experience points gained
    ldy     OBJ_Type,x
    lda     ExpTable-8,y    ; !!!
    jsr     AdjustExpGain
    jsr     AddExpPoints
    jsr     CheckLevelAdvance
    jsr     SetBigExplodeAnim
    lda     #SFX_ENEMYEXPLODE
    sta     SFX_Number+1
    lda     #SFX_NOISEEXPLODE
    sta     SFX_Number+3
    lda     #OE_DISCARDENEMY
    jmp     SetAnimWaitAction

    TestProjectileCollide:
    lda     #OT_PROJECTILE
    jmp     CheckIfCollided

    TestPlayerCollide:
    lda     #OT_PLAYER
    jmp     CheckIfCollided

    ExplodeProjectile2:
    txa
    pha
    ldx     CollObjNums,y
    jsr     ExplodeProjectile
    pla
    tax
    rts

; HurtPlayer
; ==========
; In: A = amount to hurt him

    HurtPlayer:
; subtract from health
    eor     #$FF
    sec
    adc     Health
    bpl     +
    lda     #0
  + sta     Health
; update the health meter palette
    txa
    pha
    jsr     SetHealthPal
    pla
    tax
; play "OUCH!" sample
    lda     #$0F
    sta     $4010
    lda     #$FC
    sta     $4012
    lda     #$0C
    sta     $4013
    lda     #$0F
    sta     $4015
    lda     #$1F
    sta     $4015
; check if player is dead or should merely start blinking
    lda     Health
    bne     StartPlayerBlink
; player DEAD! ... make him burst into flames
    txa
    pha
    ldx     #0
    jsr     SetBigExplodeAnim
    lda     #OE_PLAYERDEAD
    sta     OBJ_Action
    lda     #12
    sta     Timer
    lda     #$FF
    sta     RNME_LoadTune ; turn off music
    lda     #SFX_PLAYERDIE
    sta     SFX_Number+1    ; play "player explode" sample
    pla
    tax
    rts
; player is hit but not dead... make him blink
    StartPlayerBlink:
    lda     #75
    sta     OBJ_Blink       ; blink for 75 frames
    stx     Index
; put player into damaged mode
    ldx     #0
    lda     OBJ_Action
    cmp     #OE_PLAYERDUCK
    bne     +
    jsr     PlayerStandUp
  + ldy     #LOOP_PLAYERJUMP
    lda     #0
    jsr     ANIM_SetLoop
    lda     #$38
    sta     OBJ_AccelYFrac
    lda     #OE_PLAYERHURT
    sta     OBJ_Action
; apply recoil
    lda     OBJ_State
    lsr
    bcc     +
    ; recoil right
    lda     #$FF
    sta     OBJ_AccelX
    lda     #$F0
    sta     OBJ_AccelXFrac
    lda     #$01
    sta     OBJ_SpeedX
    jmp     ++
  + ; recoil left
    lda     #$00
    sta     OBJ_AccelX
    lda     #$10
    sta     OBJ_AccelXFrac
    lda     #$FF
    sta     OBJ_SpeedX
 ++ lda     #0
    sta     OBJ_SpeedXFrac
    ldx     Index
    rts

; SetBigExplodeAnim
; =================

    SetBigExplodeAnim:
    ldy     #LOOP_OBJECTBIGEXPLODE
    jmp     SetExplodeAnim+2

; SetExplodeAnim
; ==============

    SetExplodeAnim:
    ldy     #LOOP_OBJECTEXPLODE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #0
    jsr     ResetMotion
    lda     #amForward
    sta     ANIM_Method,x
    rts

; LoadBlockingDoor
; ================
; In: A = %yyyyxxxx (map)
;     Y = %yyyyxxxx (room)

    LoadBlockingDoor:
    pha
    and     #$0F
    sta     ObjPageX
    pla
    lsr
    lsr
    lsr
    lsr
    sta     ObjPageY
    txa
    pha
    jsr     FindObjSlot
    tya
    ldy     #OT_BLOCKINGDOOR
    jsr     LoadObject
    pla
    tax
    rts


.end
