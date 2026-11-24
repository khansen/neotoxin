base_actionptrtable:
;;; common actions
.dw PlayerStand
.dw PlayerRun
.dw PlayerJump
.dw PlayerFall
.dw PlayerLadder
.dw PlayerDuck
.dw PlayerDead
.dw PlayerHurt
.dw ProjectileMain
.dw ManualWarpMain
.dw InstantWarpMain
.dw ItemMain
.dw NPCMain
.dw NeoDoorMain
.dw BlockingDoorMain
.dw DiscardObject
.dw Return
.dw HealthItemMain
.dw WaitAnimEnd
.dw DiscardEnemy
;;; area-specific actions
.dw JumpingApeMain
.dw MovingMineMain
.dw LandMineMain
.dw CeilingBombMain
.dw FlyingBrainMain
.dw BombWagonMain
.dw FlyingBombMain
.dw CeilingLaserMain
.dw LaserRayMain

OE_JUMPINGAPEMAIN   EQU 20
OE_MOVINGMINEMAIN   EQU 21
OE_LANDMINEMAIN     EQU 22
OE_CEILINGBOMBMAIN  EQU 23
OE_FLYINGBRAINMAIN  EQU 24
OE_BOMBWAGONMAIN    EQU 25
OE_FLYINGBOMBMAIN   EQU 26
OE_CEILINGLASERMAIN EQU 27
OE_LASERRAYMAIN     EQU 28

OE_UPANDDOWNFLYERMAIN   EQU 99

;-----------------------------------------------------------------------------

  - rts
.proc CeilingBombMain
    lda     OBJ_AccelYFrac,x
    beq     +
    ; it's bouncing towards player
    lda     OBJ_State,x
    bpl     ++
    ; it's bounced offscreen, discard it
    jmp     DiscardObject
    ;
 ++ lda     CollStat
    and     #(COLL_LEFT + COLL_RIGHT)
    beq     ++
    ; hit wall, bounce the other way
    lda     OBJ_SpeedX,x
    jsr     XSIGN
    sta     OBJ_SpeedX,x
    ;
 ++ jsr     CheckHealthItemBounce
    jmp     LandMineMain
    ; hanging in the ceiling
  + lda     OBJ_State,x
    bmi     -
    jsr     CheckEnemyHit
    ldy     #1
    lda     OBJ_ScreenX
    sec
    sbc     OBJ_ScreenX,x
    bpl     +
    jsr     XSIGN
    ldy     #$FF
  + cmp     #64     ; is player within range?
    bcs     -
    ; drop
    tya
    sta     OBJ_SpeedX,x
    lda     #$2C
    sta     OBJ_AccelYFrac,x
  - rts
.endp
    
;-----------------------------------------------------------------------------

.proc LandMineMain
    jsr     CheckEnemyHit
    LandMineTouch:              ; hurts the player on contact (laser rays)
    jsr     IsPlayerHitAndWoundable
    bcc     -
; OUCH!
    lda     #1
    jsr     HurtPlayer
    ExplodeThing:
    lda     #SFX_ROCKETEXPLODE
    jsr     PlaySFX
; explode and dispose of bomb
    lda     #OE_DISCARDOBJECT
    jsr     SetAnimWaitAction
    jmp     SetExplodeAnim
.endp

;-----------------------------------------------------------------------------

.proc FlyingBrainMain
    ; y movement
    lda     OBJ_AccelY,x
    bpl     ++
    ; moving up
    lda     OBJ_SpeedY,x
    cmp     #$FB
    bne     +
    lda     OBJ_SpeedYFrac,x
    bne     +
    ; turn around
    lda     #$00
    sta     OBJ_AccelY,x
    lda     #$40
    sta     OBJ_AccelYFrac,x
    bpl     +
 ++ ; moving down
    lda     OBJ_SpeedY,x
    cmp     #5
    bne     +
    ; turn around
    lda     #$FF
    sta     OBJ_AccelY,x
    lda     #$C0
    sta     OBJ_AccelYFrac,x
  + jmp     EnemyMain

;-----------------------------------------------------------------------------

  - rts    
.endp
.proc JumpingApeMain
    lda     OBJ_State,x
    bmi     -
    lda     OBJ_AccelYFrac,x
    beq     +
    ; it's jumping towards player
    lda     CollStat
    and     #COLL_DOWN
    beq     ++
    lda     #0
    sta     OBJ_AccelYFrac,x
    sta     OBJ_SpeedY,x
    sta     OBJ_SpeedYFrac,x
    sta     OBJ_SpeedX,x
    jsr     RND
    and     #$1F
    sta     OBJ_Var0,x      ; wait a random amount of 0..32 frames till next jump allowed
 ++ jmp     EnemyMain
    ; standing, waiting for player to get close enough
  + jsr     FacePlayer
    ; animate
    lda     FrameCount
    lsr
    lsr
    lsr
    lsr
    and     #1
    jsr     ANIM_SetCel
    ; check if allowed to jump
    lda     OBJ_Var0,x
    beq     +
    dec     OBJ_Var0,x
    jmp     EnemyMain
    ; check if should start jumping
  + lda     OBJ_ScreenX,x
    cmp     OBJ_ScreenX
    bcc     +
    sbc     OBJ_ScreenX
    jmp     ++
  + lda     OBJ_ScreenX
    sec
    sbc     OBJ_ScreenX,x
 ++ cmp     #96     ; jump if player is closer than 96 pixels
    bcc     ++
    ; if player is attacking, start jumping anyways!
    jsr     TestProjectileCollide
    bne     +
    ; jump
 ++ ldy     #2
    lda     OBJ_ScreenX,x
    cmp     OBJ_ScreenX
    bcc     ++
    ldy     #$FE
 ++ tya
    sta     OBJ_SpeedX,x
    jsr     RND
    pha
    and     #$02
    ora     #$FC        ; random Y speed
    sta     OBJ_SpeedY,x
    pla
    and     #$0F
    ora     #$20        ; random Y accel.
    sta     OBJ_AccelYFrac,x
    lda     #2
    jsr     ANIM_SetCel
  + jmp     EnemyMain
.endp
  
;-----------------------------------------------------------------------------

.proc MovingMineMain
    lda     CollStat
    and     #(COLL_LEFT + COLL_RIGHT + COLL_PIXEL)
    beq     +
    jsr     ToggleDirection
    lda     OBJ_SpeedX,x
    jsr     XSIGN
    sta     OBJ_SpeedX,x
  + jmp     LandMineMain
.endp

;-----------------------------------------------------------------------------

.proc BombWagonMain
    lda     OBJ_State,x
    bpl     +
    rts
  + lda     #1
    sta     OBJ_RangeX,x
    jsr     OBJ_CheckMoveDown
    lda     #10
    sta     OBJ_RangeX,x
    bcc     +
    lda     CollStat
    and     #(COLL_LEFT + COLL_RIGHT + COLL_PIXEL)
    beq     ++
    ; turn around
  + jsr     InvertXSpeed
    sta     OBJ_SpeedX,x
    tya
    sta     OBJ_SpeedXFrac,x
    jsr     ToggleDirection
;
 ++ lda     FrameCount
    and     #$3F
    bne     +
    lda     ObjCount
    cmp     #20
    bcs     +
; spawn a flying bomb
    ldy     #OT_FLYINGBOMB
    jsr     SpawnObject
  + jmp     EnemyMain
.endp

;-----------------------------------------------------------------------------

.proc FlyingBombMain
    lda     OBJ_State,x
    bpl     +
    jmp     DiscardObject
  + lda     CollStat
    beq     +
    jmp     ExplodeThing
  + jmp     LandMineMain
.endp
  
;-----------------------------------------------------------------------------

.proc CeilingLaserMain
    lda     OBJ_State,x
    bpl     +
    rts
  + lda     OBJ_ScreenX
    sec
    sbc     OBJ_ScreenX,x
    bpl     +
    jsr     XSIGN
  + cmp     #64     ; is player within range?
    bcc     +
    lda     #amNoCycling
    sta     ANIM_Method,x
    rts
  + lda     ObjCount
    cmp     #20
    bcs     +
    dec     OBJ_Var0,x
    bne     +
    lda     #42
    sta     OBJ_Var0,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
; spawn a laser ray
    ldy     #OT_LASERRAY
    jsr     SpawnObject
  + rts
.endp

;-----------------------------------------------------------------------------

.proc LaserRayMain
    lda     OBJ_State,x
    bpl     +
    jmp     DiscardObject
  + lda     CollStat
    beq     +
    jmp     ExplodeThing
  + jmp     LandMineTouch
.endp
