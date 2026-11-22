plant_actionptrtable:
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
.dw ForceFieldMain
.dw MovingFieldMain

OE_FORCEFIELDMAIN   EQU 20
OE_MOVINGFIELDMAIN  EQU 21

;-----------------------------------------------------------------------------

  - rts
.proc ForceFieldMain
    lda     OBJ_State,x
    bmi     -
    lda     FrameCount
    and     #7
    bne     +
    jsr     ToggleDirection
  + lda     OBJ_Var0,x
    cmp     #4
    beq     +
    jsr     CheckPlayerHit
    lda     OBJ_Var0,x
  + jsr     GoRoutine
    
.db >(ForceFieldShow-1),        <(ForceFieldShow-1)
.db >(ForceFieldFastBlink-1),   <(ForceFieldFastBlink-1)
.db >(ForceFieldMediumBlink-1), <(ForceFieldMediumBlink-1)
.db >(ForceFieldSlowBlink-1),   <(ForceFieldSlowBlink-1)
.db >(ForceFieldHide-1),        <(ForceFieldHide-1)
.db >(ForceFieldSlowBlink-1),   <(ForceFieldSlowBlink-1)
.db >(ForceFieldMediumBlink-1), <(ForceFieldMediumBlink-1)
.db >(ForceFieldFastBlink-1),   <(ForceFieldFastBlink-1)
.endp

ForceFieldTimerTable:
.db 120,30,30,30,60,30,30,30

.proc ForceFieldShow
    lda     OBJ_State,x
    and     #$BF
    sta     OBJ_State,x
    jmp     DecForceFieldCounter
.endp

.proc ForceFieldFastBlink
    lda     OBJ_State,x
    eor     #$40
    sta     OBJ_State,x
    jmp     DecForceFieldCounter
.endp

.proc ForceFieldMediumBlink
    lda     FrameCount
    lsr
    bcc     +
    lda     OBJ_State,x
    eor     #$40
    sta     OBJ_State,x
  + jmp     DecForceFieldCounter
.endp

.proc ForceFieldSlowBlink
    lda     FrameCount
    and     #3
    bne     +
    lda     OBJ_State,x
    eor     #$40
    sta     OBJ_State,x
  + jmp     DecForceFieldCounter
.endp

.proc ForceFieldHide
    lda     OBJ_State,x
    ora     #$40
    sta     OBJ_State,x
    jmp     DecForceFieldCounter

    DecForceFieldCounter:
    dec     OBJ_Var1,x
    bne     +
    inc     OBJ_Var0,x
    lda     OBJ_Var0,x
    and     #7
    sta     OBJ_Var0,x
    tay
    lda     ForceFieldTimerTable,y
    sta     OBJ_Var1,x
  + rts
.endp

;-----------------------------------------------------------------------------

.proc MovingFieldMain
    lda     FrameCount
    and     #3
    bne     +
    jsr     ToggleDirection
  + lda     CollStat
    and     #(COLL_UP + COLL_DOWN)
    beq     +
    lda     OBJ_SpeedY,x
    jsr     XSIGN
    sta     OBJ_SpeedY,x
  + jmp     EnemyMain
.endp
