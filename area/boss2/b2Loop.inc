boss2_loopptrtable:
;;; common loops
.dw PlayerStandLoop         ; 00
.dw PlayerRunLoop           ; 01
.dw PlayerJumpLoop          ; 02
.dw PlayerDuckLoop          ; 03
.dw PlayerClimbLoop         ; 04
.dw PlayerDeadLoop          ; 05
.dw ObjectExplodeLoop       ; 06
.dw ObjectBigExplodeLoop    ; 07
.dw HealthItemLoop          ; 08
.dw RocketLoop              ; 09
.dw EnergyBulletLoop        ; 0A
.dw NPCLoop                 ; 0B
.dw ItemLoop                ; 0C
.dw NeoDoorLoop             ; 0D
.dw BlockingDoorLoop        ; 0E
;;; area-specific loops
.dw Boss2Loop

LOOP_BOSS2          EQU 15

;-----------------------------------------------------------------------------

Boss2Loop:
