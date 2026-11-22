boss1_objconstructors:
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
.dw Boss1Init           ; 08
.dw PowerCoreInit       ; 09
.dw WallEyeInit         ; 0A
.dw EnergyWaveInit      ; 0B

OT_BOSS1        EQU 8
OT_POWERCORE    EQU 9
OT_WALLEYE      EQU 10
OT_ENERGYWAVE   EQU 11

; Boss1Init
; =========
; Initialize boss 1.

.proc Boss1Init
    ldy     #LOOP_BOSS1
    lda     #0
    jsr     ANIM_SetLoop
    lda     #amForwardLoop
    sta     ANIM_Method,x
    lda     #7
    sta     OBJ_RangeX,x
    lda     #7
    sta     OBJ_RangeY,x
    lda     #10
    sta     OBJ_Health,x
    lda     #OE_BOSS1WAIT
    sta     OBJ_Action,x
    lda     #1
    sta     RoomFlags   ; blocking doors use this flag to determine when they should open
    ; set eye palette to black
    lda     #0
    jsr     Boss1SetEyePalette
    jmp     CheckPPUWrite
.endp

; PowerCoreInit
; =============

.proc PowerCoreInit
.endp

; WallEyeInit
; =============

.proc WallEyeInit
.endp

; EnergyWaveInit
; ==============

.proc EnergyWaveInit
    ; speed (TODO: should go in direction of player)
    lda     #$00
    sta     OBJ_SpeedXFrac,x
    lda     #$02
    sta     OBJ_SpeedX,x
    ;
    lda     #4
    sta     OBJ_State,x     ; ignore BG collision
    lda     #6
    sta     OBJ_RangeX,x
    lda     #6
    sta     OBJ_RangeY,x
    lda     #amForwardLoop
    sta     ANIM_Method,x
    ldy     #LOOP_ENERGYWAVE
    lda     #0
    jsr     ANIM_SetLoop
    lda     #OE_ENERGYWAVEMAIN
    sta     OBJ_Action,x
    rts
.endp
