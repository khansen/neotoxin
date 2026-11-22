boss0_loopptrtable:
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
.dw Boss0Loop               ; 0F

LOOP_BOSS0          EQU 15

;-----------------------------------------------------------------------------

Boss0Loop:
.db 10,2,2
.dw Boss0LoopCel0
.dw Boss0LoopCel1
.db CHR_BOSS0
.db CHR_BOSS0

Boss0LoopCel0:
.db 8
.db -16,$81,2,-16
.db -16,$83,2,-8
.db -16,$85,2,0
.db -16,$87,2,8
.db 0,$89,2,-16
.db 0,$8B,2,-8
.db 0,$8D,2,0
.db 0,$8F,2,8
Boss0LoopCel1:
.db 8
.db -16,$91,2,-16
.db -16,$93,2,-8
.db -16,$95,2,0
.db -16,$97,2,8
.db 0,$99,2,-16
.db 0,$9B,2,-8
.db 0,$9D,2,0
.db 0,$9F,2,8
