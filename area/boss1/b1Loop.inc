boss1_loopptrtable:
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
.dw WallEyeLoop             ; 0F
.dw Boss1Loop               ; 10
.dw EnergyWaveLoop          ; 11
.dw PowerCoreLoop           ; 12

LOOP_WALLEYE    EQU $0F
LOOP_BOSS1      EQU $10
LOOP_ENERGYWAVE EQU $11
LOOP_POWERCORE  EQU $12

;-----------------------------------------------------------------------------

WallEyeLoop:
.db 8,2,2
.dw WallEyeLoopCel0
.dw WallEyeLoopCel1

WallEyeLoopCel0:
.db 10
.db -16,$91,2,-20
.db -16,$93,2,-12
.db -16,$95,2,-4
.db -16,$97,2,4
.db -16,$99,2,12
.db 0,$9B,2,-20
.db 0,$9D,2,-12
.db 0,$9F,2,-4
.db 0,$A1,2,4
.db 0,$A3,2,12
WallEyeLoopCel1:
.db 10
.db -16,$A5,2,-20
.db -16,$A7,2,-12
.db -16,$A9,2,-4
.db -16,$AB,2,4
.db -16,$AD,2,12
.db 0,$AF,2,-20
.db 0,$B1,2,-12
.db 0,$B3,2,-4
.db 0,$B5,2,4
.db 0,$B7,2,12

;-----------------------------------------------------------------------------

Boss1Loop:
.db 1,1,2
.dw Boss1LoopCel0
.db CHR_BOSS2

Boss1LoopCel0:
.db 4
.db -16,$89,2,-12
.db -16,$8B,2,-4
.db -16,$8D,2,4
.db 0,$8F,2,4

;-----------------------------------------------------------------------------

EnergyWaveLoop:
.db 8,2,2
.dw EnergyWaveLoopCel0
.dw EnergyWaveLoopCel1
.db CHR_BOSS2
.db CHR_BOSS2

EnergyWaveLoopCel0:
.db 2
.db -16,$81,2,-8
.db -16,$83,2,0
EnergyWaveLoopCel1:
.db 2
.db -16,$85,2,-8
.db -16,$87,2,0

;-----------------------------------------------------------------------------

PowerCoreLoop:
.db 8,2,2
.dw PowerCoreLoopCel0
.dw PowerCoreLoopCel1

PowerCoreLoopCel0:
PowerCoreLoopCel1:
