plant_loopptrtable:
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
.dw ForceFieldLoop
.dw MovingFieldLoop

LOOP_FORCEFIELD         EQU 15
LOOP_MOVINGFIELD        EQU 16

;-----------------------------------------------------------------------------

ForceFieldLoop:
.db 8,1,3
.dw ForceFieldLoopCel0
.db CHR_PLANTENEMY+1

ForceFieldLoopCel0:
.db 4
.db -32,$F1,2,-4
.db -16,$F3,2,-4
.db 0,$F5,2,-4
.db 16,$F7,2,-4

;-----------------------------------------------------------------------------

MovingFieldLoop:
.db 1,1,2
.dw MovingFieldLoopCel0
.db CHR_PLANTENEMY

MovingFieldLoopCel0:
.db 2
.db -16,$B5,2,-4
.db 0,$B7,2,-4
