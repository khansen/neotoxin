base_objconstructors:
;;; common constructors
.dw PlayerInit          ; 00
.dw ProjectileInit      ; 01
.dw ManualWarpInit      ; 02
.dw InstantWarpInit     ; 03
.dw ItemInit            ; 04
.dw NPCInit             ; 05
.dw NeoDoorInit         ; 06
.dw BlockingDoorInit    ; 07
;;; area-specific constructors
.dw JumpingApeInit      ; 08
.dw MovingMineInit      ; 09
.dw LandMineInit        ; 0A
.dw CeilingBombInit     ; 0B
.dw FlyingBrainInit     ; 0C
.dw BombWagonInit       ; 0D
.dw FlyingBombInit      ; 0E
.dw CeilingLaserInit    ; 0F
.dw LaserRayInit        ; 10

OT_JUMPINGAPE   EQU $08
OT_MOVINGMINE   EQU $09
OT_LANDMINE     EQU $0A
OT_CEILINGBOMB  EQU $0B
OT_FLYINGBRAIN  EQU $0C
OT_BOMBWAGON    EQU $0D
OT_FLYINGBOMB   EQU $0E
OT_CEILINGLASER EQU $0F
OT_LASERRAY     EQU $10

;-----------------------------------------------------------------------------

.proc CeilingBombInit
    lda     OBJ_WorldYLo,x
    ora     #8
    sta     OBJ_WorldYLo,x
    lda     OBJ_WorldXLo,x
    ora     #8
    sta     OBJ_WorldXLo,x
    ldy     #LOOP_CEILINGBOMB
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #5
    sta     OBJ_RangeX,x
    sta     OBJ_RangeY,x
    lda     #4
    sta     OBJ_Health,x
    lda     #OE_CEILINGBOMBMAIN
    sta     OBJ_Action,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc LandMineInit
    lda     OBJ_WorldYLo,x
    clc
    adc     #12
    sta     OBJ_WorldYLo,x
    ldy     #LOOP_LANDMINE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #6
    sta     OBJ_RangeX,x
    lda     #4
    sta     OBJ_RangeY,x
    lda     #3
    sta     OBJ_Health,x
    lda     #OE_LANDMINEMAIN
    sta     OBJ_Action,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc FlyingBrainInit
    ldy     #LOOP_FLYINGBRAIN
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #7
    sta     OBJ_RangeX,x
    lda     #7
    sta     OBJ_RangeY,x
    lda     #8
    sta     OBJ_Health,x
    lda     #OE_FLYINGBRAINMAIN
    sta     OBJ_Action,x
    lda     #5
    sta     OBJ_SpeedY,x
    ; start moving towards player
    lda     #$80
    sta     OBJ_SpeedXFrac,x
    jsr     FaceRight
    lda     OBJ_WorldXHi,x
    cmp     OBJ_WorldXHi
    bcc     +
    lda     #$FF
    sta     OBJ_SpeedX,x
    jsr     FaceLeft
  + lda     OBJ_State,x
    ora     #4      ; ignore BG collision
    sta     OBJ_State,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc JumpingApeInit
    lda     OBJ_WorldYLo,x
    ora     #7
    sta     OBJ_WorldYLo,x
    ldy     #LOOP_JUMPINGAPE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #11
    sta     OBJ_RangeX,x
    lda     #8
    sta     OBJ_RangeY,x
    lda     #10
    sta     OBJ_Health,x
    lda     #OE_JUMPINGAPEMAIN
    sta     OBJ_Action,x
    jsr     RND
    and     #$1F
    sta     OBJ_Var0,x      ; wait a random amount of 0..32 frames till first jump allowed
    rts
.endp

;-----------------------------------------------------------------------------

.proc MovingMineInit
    ldy     #LOOP_MOVINGMINE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #6
    sta     OBJ_RangeX,x
    sta     OBJ_RangeY,x
    lda     #6
    sta     OBJ_Health,x
    lda     #OE_MOVINGMINEMAIN
    sta     OBJ_Action,x
    lda     #$FF
    sta     OBJ_SpeedX,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc BombWagonInit
    lda     OBJ_WorldYLo,x
    ora     #8
    sta     OBJ_WorldYLo,x
    ldy     #LOOP_BOMBWAGON
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #10
    sta     OBJ_RangeX,x
    lda     #7
    sta     OBJ_RangeY,x
    lda     #6
    sta     OBJ_Health,x
    lda     #OE_BOMBWAGONMAIN
    sta     OBJ_Action,x
    ; start moving towards player
    lda     #$80
    sta     OBJ_SpeedXFrac,x
    jsr     FaceRight
    lda     OBJ_WorldXHi,x
    cmp     OBJ_WorldXHi
    bcc     +
    lda     #$FF
    sta     OBJ_SpeedX,x
    jsr     FaceLeft
  + rts
.endp

;-----------------------------------------------------------------------------

.proc FlyingBombInit
    ldy     #LOOP_FLYINGBOMB
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #6
    sta     OBJ_RangeX,x
    lda     #6
    sta     OBJ_RangeY,x
    lda     #1
    sta     OBJ_Health,x
    lda     Random
    inc     Random
    lsr
    lda     #$FB
    bcc     +
    lda     #$FD
  + sta     OBJ_SpeedY,x
    lda     #$28
    sta     OBJ_AccelYFrac,x
    lda     Random
    inc     Random
    and     #7
    tay
    lda     FlyingBombStartSpeedXTable,y
    sta     OBJ_SpeedX,x
    lda     #OE_FLYINGBOMBMAIN
    sta     OBJ_Action,x
    rts
.endp

FlyingBombStartSpeedXTable:
.db 2,-2,2,-2,-2,2,-2,2

;-----------------------------------------------------------------------------

.proc CeilingLaserInit
    lda     OBJ_WorldYLo,x
    ora     #8
    sta     OBJ_WorldYLo,x
    ldy     #LOOP_CEILINGLASER
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #7
    sta     OBJ_RangeX,x
    lda     #6
    sta     OBJ_RangeY,x
    lda     #4
    sta     OBJ_Health,x
    lda     #1
    sta     OBJ_Var0,x
    lda     #OE_CEILINGLASERMAIN
    sta     OBJ_Action,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc LaserRayInit
    ldy     #LOOP_LASERRAY
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #4
    sta     OBJ_RangeX,x
    lda     #7
    sta     OBJ_RangeY,x
    lda     #4
    sta     OBJ_SpeedY,x
    lda     #OE_LASERRAYMAIN
    sta     OBJ_Action,x
    rts
.endp
