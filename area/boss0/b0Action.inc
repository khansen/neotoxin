boss0_actionptrtable:
;;; common actions
.dw PlayerStand         ; 00
.dw PlayerRun           ; 01
.dw PlayerJump          ; 02
.dw PlayerFall          ; 03
.dw PlayerLadder        ; 04
.dw PlayerDuck          ; 05
.dw PlayerDead          ; 06
.dw PlayerHurt          ; 07
.dw ProjectileMain      ; 08
.dw ManualWarpMain      ; 09
.dw InstantWarpMain     ; 0A
.dw ItemMain            ; 0B
.dw NPCMain             ; 0C
.dw NeoDoorMain         ; 0D
.dw BlockingDoorMain    ; 0E
.dw DiscardObject       ; 0F
.dw Return              ; 10
.dw HealthItemMain      ; 11
.dw WaitAnimEnd         ; 12
.dw DiscardEnemy        ; 13
;;; area-specific actions
.dw Boss0Wait
.dw Boss0Startup
.dw Boss0Main

OE_BOSS0WAIT            EQU 20
OE_BOSS0STARTUP         EQU 21
OE_BOSS0MAIN            EQU 22

;-----------------------------------------------------------------------------

; Boss0Wait
; =========
; Waits for the player to approach.

.proc Boss0Wait
    lda     OBJ_State,x
    bmi     +           ; exit if not visible
    lda     OBJ_Var0,x
    beq     ++          ; branch if counter expired
    dec     OBJ_Var0,x  ; else decrement...
  - rts                 ; and exit.
    ; boss is visible to player
 ++ lda     OBJ_Action
    cmp     #OE_PLAYERSTAND
    beq     ++
    cmp     #OE_PLAYERRUN
    bne     -           ; player is jumping or something, wait till he lands
    txa
    pha
    ldx     #0
    jsr     SetStanding
    pla
    tax
    ; next phase
 ++ jsr     ProgramControl
    lda     #OE_BOSS0STARTUP
    sta     OBJ_Action,x    ; action triggered after cutscene
    lda     #<Boss0IntroScript
    ldy     #>Boss0IntroScript
    jmp     LoadScript  ; initiate the boss intro cutscene
.endp

;-----------------------------------------------------------------------------

; Boss0Startup
; ============

.proc Boss0Startup
    ; load left door
    lda     #$10
    ldy     #$61
    jsr     LoadBlockingDoor
    ; load right door
    lda     #$11
    ldy     #$6E
    jsr     LoadBlockingDoor
    ; setup boss's start motion
    lda     #2
    sta     OBJ_SpeedX,x
    lda     #$80
    sta     OBJ_SpeedXFrac,x
    lda     #5
    sta     OBJ_SpeedY,x
    ; play boss music
    lda     #14
    sta     RNME_LoadTune
    ;
    lda     #OE_BOSS0MAIN
    sta     OBJ_Action,x
    jmp     PlayerControl
.endp
    
;-----------------------------------------------------------------------------

; Boss0Main
; =========

.proc Boss0Main
    lda     OBJ_State,x
    bpl     +
    jsr     MoveXDir
    jsr     CheckObjColl
  + lda     CollStat
    beq     +
    jsr     InvertXSpeed
    sta     OBJ_SpeedX,x
    jsr     ToggleDirection
  + ;    UpAndDownFlyerMain:
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
    lda     #$80
    sta     OBJ_AccelYFrac,x
    bpl     +
 ++ ; moving down
    lda     OBJ_SpeedY,x
    cmp     #5
    bne     +
    ; turn around
    lda     #$FF
    sta     OBJ_AccelY,x
    lda     #$80
    sta     OBJ_AccelYFrac,x
  + ;
    jsr     EnemyMain
    lda     OBJ_Health,x
    bne     +
    ; boss dead
    lda     #10
    sta     RNME_LoadTune
    lda     #0
    sta     RoomFlags
  + rts
.endp
