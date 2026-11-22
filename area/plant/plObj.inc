plant_objconstructors:
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
.dw ForceFieldInit      ; 08
.dw MovingFieldInit     ; 09

OT_FORCEFIELD   EQU $08
OT_MOVINGFIELD  EQU $09

;-----------------------------------------------------------------------------

    ForceFieldInit:
    ldy     #LOOP_FORCEFIELD
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #3
    sta     OBJ_RangeX,x
    lda     #31
    sta     OBJ_RangeY,x
    lda     #OE_FORCEFIELDMAIN
    sta     OBJ_Action,x
    lda     #4
    sta     OBJ_State,x
    lda     #0
    sta     OBJ_Var0,x
    lda     ForceFieldTimerTable
    sta     OBJ_Var1,x
    rts

;-----------------------------------------------------------------------------

    MovingFieldInit:
    ldy     #LOOP_MOVINGFIELD
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amNoCycling
    sta     ANIM_Method,x
    lda     #3
    sta     OBJ_RangeX,x
    lda     #15
    sta     OBJ_RangeY,x
    lda     #5
    sta     OBJ_Health,x
    lda     #OE_MOVINGFIELDMAIN
    sta     OBJ_Action,x
    lda     #$FF
    sta     OBJ_SpeedY,x
    rts
