ruins_objconstructors:
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
.dw AcidZombieInit      ; 08
.dw BigBirdInit         ; 09

OT_ENEMY0   EQU 8
OT_ENEMY1   EQU 9
OT_ENEMY2   EQU 10
OT_ENEMY3   EQU 11
OT_ENEMY4   EQU 12
OT_ENEMY5   EQU 13
OT_ENEMY6   EQU 14
OT_ENEMY7   EQU 15

;-----------------------------------------------------------------------------

.proc AcidZombieInit
    lda     OBJ_WorldYLo,x
    ora     #7
    sta     OBJ_WorldYLo,x
    ldy     #LOOP_ACIDZOMBIE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #7
    sta     OBJ_RangeX,x
    lda     #23
    sta     OBJ_RangeY,x
    lda     #3
    sta     OBJ_Health,x
    lda     #OE_ACIDZOMBIEMAIN
    sta     OBJ_Action,x
    lda     #0
    sta     OBJ_Var0,x
    lda     #$40
    sta     OBJ_AccelYFrac,x
    rts
.endp

;-----------------------------------------------------------------------------

.proc BigBirdInit
    ldy     #LOOP_BIGBIRD
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #20
    sta     OBJ_RangeX,x
    lda     #15
    sta     OBJ_RangeY,x
    lda     #5
    sta     OBJ_Health,x
    lda     #OE_BIGBIRDMAIN
    sta     OBJ_Action,x
    jsr     RND
    and     #$3F
    ora     #$01
    sta     OBJ_Var0,x    
    lda     #1
    sta     OBJ_Var1,x  ; standing still
    rts
.endp
