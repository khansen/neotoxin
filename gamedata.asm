.include "game.h"

.codeseg

.public GameDemos
.public InitialSaveGame
.public BitMaskTable
.public ExpPtsLevelTable
.public EnemyDamageTable
.public ProjectileDamageTable
.public ExpTable

;----------------------------------[ Data ]-----------------------------------

InitialSaveGame:
.db INITIAL_HEALTH  ; Health
.db INITIAL_DEFENSE ; HealthFrac
.db 0   ; Level
.db INITIAL_MAXHEALTH ; MaxHealth
.db INITIAL_DEFENSE  ; Defense
.dw 0   ; Experience
.db 32  ; ExpFrac
.db 0   ; Hours
.db 0   ; Minutes
.db 0   ; Seconds
.db 0   ; Clockticks
.db 2   ; Area
.db 0   ; Section
.db 0   ; Warp #
.db 0   ; WarpType
.db 0   ; ProjectileType

ExpPtsLevelTable:
.dw 100,250,500,750,1000,1500,2000,2500,3000,4000,5000,6000,7500
.dw 10000,15000,20000,25000,30000,35000,40000,45000,50000,55000,60000,65000

EnemyDamageTable:
.db 1,2,2,3,3,4,4,5,5,6,6,7,7,8,8

ProjectileDamageTable:
.db 1,2,1,1,1,1,1,1,1,1,1

ExpTable:
.db 5,10,15,20,25,30,35,40,45,50

BitMaskTable:
.db %00000001
.db %00000010
.db %00000100
.db %00001000
.db %00010000
.db %00100000
.db %01000000
.db %10000000

GameDemos:
.dw demo0
demo0:
.incbin "data/demo.dat"


.end
