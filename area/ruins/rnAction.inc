ruins_actionptrtable:
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
.dw AcidZombieMain
.dw BigBirdMain

OE_ACIDZOMBIEMAIN   EQU 20
OE_BIGBIRDMAIN      EQU 21

;-----------------------------------------------------------------------------

  - rts
.proc AcidZombieMain
    lda     OBJ_State,x
    bmi     -
    lda     OBJ_Var0,x
    beq     +
    dec     OBJ_Var0,x
    lda     #8  ; HACK!!!
    jsr     CheckIfCollided ; bumped into another zombie?
    beq     @@acidzombieturnaround
    lda     CollStat
    and     #(COLL_LEFT + COLL_RIGHT)
    beq     ++
    @@acidzombieturnaround:
    jsr     ToggleDirection
    jsr     InvertXSpeed
    sta     OBJ_SpeedX,x
    tya
    sta     OBJ_SpeedXFrac,x
    ; if player is attacking, start walking anyways!
 ++ jsr     TestProjectileCollide
    bne     ++
    lda     #1
    jsr     GetStatusFlag
    bne     +++
    lda     #1
    jsr     SetStatusFlag
    lda     #<ZombieScript
    ldy     #>ZombieScript
    jsr     LoadScript
+++
    ; chase player
    lda     #100
    sta     OBJ_Var0,x  ; chase him for at least 100 frames
    lda     OBJ_ScreenX
    cmp     OBJ_ScreenX,x
    bcc     @@AcidZombieWalkLeft
    bcs     @@AcidZombieWalkRight
 ++ jmp     EnemyMain
    ; timer is zero, time to do something
  + jsr     RND
    pha
    ora     #$80
    sta     OBJ_Var0,x  ; # of frames to walk
    lda     #$80
    sta     OBJ_SpeedXFrac,x
    pla
    lsr
    bcc     @@AcidZombieWalkRight
    ; walk left
    @@AcidZombieWalkLeft:
    lda     #$FF
    sta     OBJ_SpeedX,x
    jsr     FaceLeft
    jmp     EnemyMain
    ; walk right
    @@AcidZombieWalkRight:
    lda     #$00
    sta     OBJ_SpeedX,x
    jsr     FaceRight
    jmp     EnemyMain

;-----------------------------------------------------------------------------

  - rts
.endp
.proc BigBirdMain
    lda     OBJ_State,x
    bmi     -

    lda     OBJ_Var1,x  ; mode
    beq     @@BigBirdFly

    dec     OBJ_Var0,x
    bne     +
    ; start flying
    jsr     RND
  - sta     OBJ_Var0,x    ; fly this many frames
    lda     #0
    sta     OBJ_Var1,x  ; fly mode
    jmp     EnemyMain
  + jsr     TestProjectileCollide
    bne     +
    ; if player is attacking, start flying anyways!
    lda     #$FE
    sta     OBJ_SpeedY,x
    lda     #$00
    sta     OBJ_SpeedYFrac,x
    lda     #100
    bne     -
  + jmp     EnemyMain

    @@BigBirdFly:
    dec     OBJ_Var0,x
    bne     +
    ; stop flying
    lda     #0
    jsr     ResetMotion
    jsr     RND
    and     #$7F
    ora     #$01
    sta     OBJ_Var0,x  ; stop for this many frames
    lda     #1
    sta     OBJ_Var1,x  ; stop mode
    jmp     EnemyMain
    ; X movement
  + lda     OBJ_ScreenX
    cmp     OBJ_ScreenX,x
    bcs     @@BirdPlayerRight
    ; player to the left
    lda     OBJ_ScreenX,x
    sec
    sbc     OBJ_ScreenX
    lsr
    lsr
    eor     #$FF
    sta     OBJ_AccelXFrac,x
    lda     #$FF
    sta     OBJ_AccelX,x
    bmi     @@BirdY
    ; player to the right
    @@BirdPlayerRight:
    lda     OBJ_ScreenX
    sec
    sbc     OBJ_ScreenX,x
    lsr
    lsr
    sta     OBJ_AccelXFrac,x
    lda     #$00
    sta     OBJ_AccelX,x
    ; Y movement
    @@BirdY:
    lda     OBJ_ScreenY
    cmp     OBJ_ScreenY,x
    bcs     @@BirdPlayerDown
    ; player up
    lda     OBJ_ScreenY,x
    sec
    sbc     OBJ_ScreenY
    lsr
    lsr
    eor     #$FF
    sta     OBJ_AccelYFrac,x
    lda     #$FF
    sta     OBJ_AccelY,x
    bmi     +
    ; player down
    @@BirdPlayerDown:
    lda     OBJ_ScreenY
    sec
    sbc     OBJ_ScreenY,x
    lsr
    lsr
    sta     OBJ_AccelYFrac,x
    lda     #$00
    sta     OBJ_AccelY,x
  + 
    lda     OBJ_SpeedX,x
    bmi     +
    cmp     #2
    bcc     ++
    lda     #0
    sta     OBJ_SpeedXFrac,x
    lda     #2
    bne     ++
  + cmp     #$FE
    bcs     ++
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$FE
 ++ sta     OBJ_SpeedX,x
;
    lda     OBJ_SpeedY,x
    bmi     +
    cmp     #2
    bcc     ++
    lda     #0
    sta     OBJ_SpeedYFrac,x
    lda     #2
    bne     ++
  + cmp     #$FE
    bcs     ++
    lda     #$00
    sta     OBJ_SpeedYFrac,x
    lda     #$FE
 ++ sta     OBJ_SpeedY,x
    ;
    jmp     EnemyMain
.endp
