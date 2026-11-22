boss2_objconstructors:
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
.dw Boss2Init           ; 08

; Boss2Init
; =========

    Boss2Init:
    ldy     #LOOP_BOSS2
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #12
    sta     OBJ_RangeX,x
    lda     #14
    sta     OBJ_RangeY,x
    lda     #10
    sta     OBJ_Health,x
    lda     #120
    sta     OBJ_Var0,x
    lda     #OE_BOSS2WAIT
    sta     OBJ_Action,x
    lda     #1
    sta     RoomFlags   ; boss alive
    rts
