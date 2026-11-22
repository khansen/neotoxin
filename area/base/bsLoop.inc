base_loopptrtable:
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
.dw JumpingApeLoop
.dw MovingMineLoop
.dw LandMineLoop
.dw CeilingBombLoop
.dw FlyingBrainLoop
.dw BombWagonLoop
.dw FlyingBombLoop
.dw CeilingLaserLoop
.dw LaserRayLoop

LOOP_JUMPINGAPE         EQU 15
LOOP_MOVINGMINE         EQU 16
LOOP_LANDMINE           EQU 17
LOOP_CEILINGBOMB        EQU 18
LOOP_FLYINGBRAIN        EQU 19
LOOP_BOMBWAGON          EQU 20
LOOP_FLYINGBOMB         EQU 21
LOOP_CEILINGLASER       EQU 22
LOOP_LASERRAY           EQU 23

;-----------------------------------------------------------------------------

MovingMineLoop:
.db 6,2,2
.dw MovingMineLoopCel0
.dw MovingMineLoopCel1
.db CHR_BASEENEMY
.db CHR_BASEENEMY

MovingMineLoopCel0:
.db 2
.db -8,$81,2,-8
.db -8,$83,2,0
MovingMineLoopCel1:
.db 2
.db -8,$85,2,-8
.db -8,$87,2,0

;-----------------------------------------------------------------------------

LandMineLoop:
.db 8,2,2
.dw LandMineLoopCel0
.dw LandMineLoopCel1
.db CHR_BASEENEMY
.db CHR_BASEENEMY

LandMineLoopCel0:
.db 2
.db -8,$89,2,-8
.db -8,$8B,2,0
LandMineLoopCel1:
.db 2
.db -8,$8D,2,-8
.db -8,$8F,2,0

;-----------------------------------------------------------------------------

CeilingBombLoop:
.db 8,2,3
.dw CeilingBombLoopCel0
.dw CeilingBombLoopCel1
.db CHR_BASEENEMY+1
.db CHR_BASEENEMY+1

CeilingBombLoopCel0:
.db 2
.db -8,$D9,2,-8
.db -8,$DB,2,0
CeilingBombLoopCel1:
.db 2
.db -8,$DD,2,-8
.db -8,$DF,2,0

;-----------------------------------------------------------------------------

JumpingApeLoop:
.db 10,3,3
.dw JumpingApeLoopCel0
.dw JumpingApeLoopCel1
.dw JumpingApeLoopCel2
.db CHR_BASEENEMY+1
.db CHR_BASEENEMY+1
.db CHR_BASEENEMY+1

JumpingApeLoopCel0:
.db 3
.db -8,$C1,2,-12
.db -8,$C3,2,-4
.db -8,$C5,2,4
JumpingApeLoopCel1:
.db 3
.db -8,$C7,2,-12
.db -8,$C9,2,-4
.db -8,$CB,2,4
JumpingApeLoopCel2:
.db 6
.db -16,$CD,2,-12
.db -16,$CF,2,-4
.db -16,$D1,2,4
.db 0,$D3,2,-12
.db 0,$D5,2,-4
.db 0,$D7,2,4

;-----------------------------------------------------------------------------

FlyingBrainLoop:
.db 16,2,2
.dw FlyingBrainLoopCel0
.dw FlyingBrainLoopCel1
.db CHR_BASEENEMY
.db CHR_BASEENEMY

FlyingBrainLoopCel0:
.db 4
.db -8,$91,2,-12
.db -8,$93,2,-4
.db -8,$95,2,4
.db 8,$97,2,-4
FlyingBrainLoopCel1:
.db 4
.db -8,$99,2,-12
.db -8,$9B,2,-4
.db -8,$9D,2,4
.db 8,$9F,2,-4

;-----------------------------------------------------------------------------

BombWagonLoop:
.db 8,2,2
.dw BombWagonLoopCel0
.dw BombWagonLoopCel1
.db CHR_BASEENEMY
.db CHR_BASEENEMY

BombWagonLoopCel0:
.db 3
.db -8,$A5,2,-12
.db -8,$A7,2,-4
.db -8,$A9,2,4
BombWagonLoopCel1:
.db 3
.db -8,$AB,2,-12
.db -8,$AD,2,-4
.db -8,$AF,2,4

;-----------------------------------------------------------------------------

FlyingBombLoop:
.db 4,4,2
.dw FlyingBombLoopCel0
.dw FlyingBombLoopCel1
.dw FlyingBombLoopCel2
.dw FlyingBombLoopCel3
.db CHR_BASEENEMY
.db CHR_BASEENEMY
.db CHR_BASEENEMY
.db CHR_BASEENEMY

FlyingBombLoopCel0:
.db 2
.db -8,$B1,2,-8
.db -8,$B3,2,0
FlyingBombLoopCel1:
.db 2
.db -8,$B5,2,-8
.db -8,$B7,2,0
FlyingBombLoopCel2:
.db 2
.db -8,$B9,2,-8
.db -8,$BB,2,0
FlyingBombLoopCel3:
.db 2
.db -8,$BD,2,-8
.db -8,$BF,2,0

;-----------------------------------------------------------------------------

CeilingLaserLoop:
.db 16,2,2
.dw CeilingLaserLoopCel0
.dw CeilingLaserLoopCel1
.db CHR_BASEENEMY
.db CHR_BASEENEMY

CeilingLaserLoopCel0:
.db 2
.db -8,$A1,2,-8
.db -8,$A3,2,0
CeilingLaserLoopCel1:
.db 2
.db -10,$A1,2,-8
.db -10,$A3,2,0

;-----------------------------------------------------------------------------

LaserRayLoop:
.db 1,1,3
.dw LaserRayLoopCel0
.db CHR_BASEENEMY+1

LaserRayLoopCel0:
.db 2
.db -8,$E1,2,-8
.db -8,$E1,2,0
