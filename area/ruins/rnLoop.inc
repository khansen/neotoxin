ruins_loopptrtable:
;;; common loops
.dw PlayerStandLoop
.dw PlayerRunLoop
.dw PlayerJumpLoop
.dw PlayerDuckLoop
.dw PlayerClimbLoop
.dw PlayerDeadLoop
.dw ObjectExplodeLoop
.dw ObjectBigExplodeLoop
.dw HealthItemLoop
.dw RocketLoop
.dw EnergyBulletLoop
.dw NPCLoop
.dw ItemLoop
.dw NeoDoorLoop
.dw BlockingDoorLoop
;;; area-specific loops
.dw AcidZombieLoop
.dw BigBirdLoop

LOOP_ACIDZOMBIE         EQU 15
LOOP_BIGBIRD            EQU 16

;-----------------------------------------------------------------------------

AcidZombieLoop:
.db 16,2,3
.dw AcidZombieLoopCel0
.dw AcidZombieLoopCel1
.db CHR_RUINSENEMY+1
.db CHR_RUINSENEMY+1

AcidZombieLoopCel0:
.db 9
.db -24,$C1,2,-8
.db -24,$C3,2,-0
.db -24,$C5,2,8
.db -8,$C7,2,-8
.db -8,$C9,2,0
.db -8,$CB,2,8
.db 8,$CD,2,-8
.db 8,$CF,2,0
.db 8,$D1,2,8
AcidZombieLoopCel1:
.db 9
.db -24,$D3,2,-8
.db -24,$D5,2,0
.db -24,$D7,2,8
.db -8,$D9,2,-8
.db -8,$DB,2,0
.db -8,$DD,2,8
.db 8,$DF,2,-8
.db 8,$E1,2,0
.db 8,$E3,2,8

;-----------------------------------------------------------------------------

BigBirdLoop:
.db 8,2,2
.dw BigBirdLoopCel0
.dw BigBirdLoopCel1
.db CHR_RUINSENEMY
.db CHR_RUINSENEMY

BigBirdLoopCel0:
.db 8
.db -16,$81,3,-16
.db -16,$83,3,-8
.db -16,$85,3,0
.db -16,$87,3,8
.db 0,$89,3,-16
.db 0,$8B,3,-8
.db 0,$8D,3,0
.db 0,$8F,3,8

BigBirdLoopCel1:
.db 12
.db -16,$91,3,-24
.db -16,$93,3,-16
.db -16,$95,3,-8
.db -16,$97,3,0
.db -16,$99,3,8
.db -16,$9B,3,16
.db 0,$9D,3,-24
.db 0,$9F,3,-16
.db 0,$A1,3,-8
.db 0,$A3,3,0
.db 0,$A5,3,8
.db 0,$A7,3,16
