.include "chr.h"

.codeseg

.public PlayerStandLoop
.public PlayerRunLoop
.public PlayerJumpLoop
.public PlayerDuckLoop
.public PlayerClimbLoop
.public PlayerDeadLoop
.public ObjectExplodeLoop
.public ObjectBigExplodeLoop
.public HealthItemLoop
.public RocketLoop
.public EnergyBulletLoop
.public NPCLoop
.public ItemLoop
.public NeoDoorLoop
.public BlockingDoorLoop

;-----------------------------------------------------------------------------

PlayerStandLoop:
.db 1,2,0
.dw PlayerStandCel0
.dw PlayerStandCel1
.db CHR_GUYSTAND1
.db CHR_GUYSTAND1

; standing
PlayerStandCel0:
.db 6
.db -24,$01,0,-8
.db -24,$03,0,0
.db -8,$05,0,-8
.db -8,$07,0,0
.db 8,$09,0,-8
.db 8,$0B,0,0

; standing & shooting
PlayerStandCel1:
.db 6
.db -24,$0D,0,-8
.db -24,$0F,0,0
.db -8,$11,0,-8
.db -8,$13,0,0
.db 8,$15,0,-8
.db 8,$17,0,0

;-----------------------------------------------------------------------------

PlayerRunLoop:
.db 6,6,0
.dw PlayerRunLoopCel0
.dw PlayerRunLoopCel1
.dw PlayerRunLoopCel2
.dw PlayerRunLoopCel0
.dw PlayerRunLoopCel1
.dw PlayerRunLoopCel2
.db CHR_GUYRUN1
.db CHR_GUYRUN1
.db CHR_GUYRUN1
.db CHR_GUYRUN2
.db CHR_GUYRUN2
.db CHR_GUYRUN2

PlayerRunLoopCel0:
.db 9
.db -24,$01,0,-12
.db -24,$03,0,-4
.db -24,$05,0,4
.db -8,$07,0,-12
.db -8,$09,0,-4
.db -8,$0B,0,4
.db 8,$0D,0,-12
.db 8,$0F,0,-4
.db 8,$11,0,4
PlayerRunLoopCel1:
.db 9
.db -24,$13,0,-12
.db -24,$15,0,-4
.db -24,$17,0,4
.db -8,$19,0,-12
.db -8,$1B,0,-4
.db -8,$1D,0,4
.db 8,$1F,0,-12
.db 8,$21,0,-4
.db 8,$23,0,4
PlayerRunLoopCel2:
.db 9
.db -24,$25,0,-12
.db -24,$27,0,-4
.db -24,$29,0,4
.db -8,$2B,0,-12
.db -8,$2D,0,-4
.db -8,$2F,0,4
.db 8,$31,0,-12
.db 8,$33,0,-4
.db 8,$35,0,4

;-----------------------------------------------------------------------------

PlayerJumpLoop:
.db 1,2,0
.dw PlayerJumpCel0
.dw PlayerJumpCel1
.db CHR_GUYJUMP1
.db CHR_GUYJUMP1

; jumping
PlayerJumpCel0:
.db 6
.db -24,$0D,0,-8
.db -24,$0F,0,0
.db -8,$11,0,-8
.db -8,$13,0,0
.db 8,$15,0,-8
.db 8,$17,0,0
; jumping and shooting
PlayerJumpCel1:
.db 6
.db -24,$01,0,-8
.db -24,$03,0,0
.db -8,$05,0,-8
.db -8,$07,0,0
.db 8,$09,0,-8
.db 8,$0B,0,0

;-----------------------------------------------------------------------------

PlayerDuckLoop:
.db 1,2,0
.dw PlayerDuckCel0
.dw PlayerDuckCel1
.db CHR_GUYDUCK1
.db CHR_GUYDUCK1

; ducking
PlayerDuckCel0:
.db 9
.db -18,$01,0,-8
.db -18,$03,0,0
.db -2,$05,0,-8
.db -2,$07,0,0
.db -2,$09,0,8
.db 14,$0B,0,-8
.db 14,$0D,0,0
.db 14,$0F,0,8
.db 14,$11,0,-16

; ducking & shooting
PlayerDuckCel1:
.db 9
.db -18,$13,0,-8
.db -18,$15,0,0
.db -2,$17,0,-8
.db -2,$19,0,0
.db -2,$1B,0,8
.db 14,$1D,0,-8
.db 14,$1F,0,0
.db 14,$21,0,8
.db 14,$23,0,-16

;-----------------------------------------------------------------------------

PlayerClimbLoop:
.db 6,2,0
.dw PlayerClimbCel0
.dw PlayerClimbCel1
.db CHR_GUYCLIMB1
.db CHR_GUYCLIMB1

PlayerClimbCel0:
PlayerClimbCel1:

;-----------------------------------------------------------------------------

PlayerDeadLoop:
.db 1,1,0
.dw PlayerDeadCel0
.db CHR_GUYDEAD1

PlayerDeadCel0:

;-----------------------------------------------------------------------------

ObjectExplodeLoop:
.db 6,4,1
.dw ObjectExplodeLoopCel0
.dw ObjectExplodeLoopCel1
.dw ObjectExplodeLoopCel2
.dw ObjectExplodeLoopCel3
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS

ObjectExplodeLoopCel0:
.db 1
.db -8,$61,0,-4
ObjectExplodeLoopCel1:
.db 1
.db -8,$63,0,-4
ObjectExplodeLoopCel2:
.db 2
.db -8,$65,0,-8
.db -8,$67,0,0
ObjectExplodeLoopCel3:
.db 2
.db -8,$69,0,-8
.db -8,$6B,0,0

;-----------------------------------------------------------------------------

ObjectBigExplodeLoop:
.db 5,8,1
.dw ObjectBigExplodeLoopCel0
.dw ObjectBigExplodeLoopCel1
.dw ObjectBigExplodeLoopCel2
.dw ObjectBigExplodeLoopCel3
.dw ObjectBigExplodeLoopCel4
.dw ObjectBigExplodeLoopCel5
.dw ObjectBigExplodeLoopCel6
.dw ObjectBigExplodeLoopCel7
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS
.db CHR_STATUS

ObjectBigExplodeLoopCel0:
.db 1
.db -8,$61,0,-4     ; 0.0
ObjectBigExplodeLoopCel1:
.db 2
.db -8,$63,0,-4     ; 0.1
.db -16,$61,0,-12   ; 1.0
ObjectBigExplodeLoopCel2:
.db 4
.db -8,$65,0,-8     ; 0.2
.db -8,$67,0,0
.db -16,$63,0,-12   ; 1.1
.db 0,$61,0,4       ; 2.0
ObjectBigExplodeLoopCel3:
.db 6
.db -8,$69,0,-8     ; 0.3
.db -8,$6B,0,0
.db -16,$65,0,-16   ; 1.2
.db -16,$67,0,-8
.db 0,$63,0,4       ; 2.1
.db -16,$61,0,4     ; 3.0
ObjectBigExplodeLoopCel4:
.db 6
.db -16,$69,0,-16   ; 1.3
.db -16,$6B,0,-8
.db 0,$65,0,0       ; 2.2
.db 0,$67,0,8
.db -16,$63,0,4     ; 3.1
.db 0,$61,0,-12     ; 4.0
ObjectBigExplodeLoopCel5:
.db 5
.db 0,$69,0,0       ; 2.3
.db 0,$6B,0,8
.db -16,$65,0,0     ; 3.2
.db -16,$67,0,8
.db 0,$63,0,-12     ; 4.1
ObjectBigExplodeLoopCel6:
.db 4
.db -16,$69,0,0     ; 3.3
.db -16,$6B,0,8
.db 0,$65,0,-16     ; 4.2
.db 0,$67,0,-8
ObjectBigExplodeLoopCel7:
.db 2
.db 0,$69,0,-16     ; 4.3
.db 0,$6B,0,-8

;-----------------------------------------------------------------------------

HealthItemLoop:
.db 6,2,1
.dw HealthItemLoopCel0
.dw HealthItemLoopCel1
.db CHR_STATUS
.db CHR_STATUS

HealthItemLoopCel0:
.db 2
.db -8,$51,0,-8
.db -8,$53,0,0
HealthItemLoopCel1:
.db 2
.db -8,$55,0,-8
.db -8,$57,0,0

;-----------------------------------------------------------------------------

RocketLoop:
.db 7,2,1
.dw RocketLoopCel0
.dw RocketLoopCel1
.db CHR_STATUS
.db CHR_STATUS

RocketLoopCel0:
.db 2
.db -8,$59,0,-8
.db -8,$5B,0,0
RocketLoopCel1:
.db 2
.db -8,$5D,0,-8
.db -8,$5F,0,0

;-----------------------------------------------------------------------------

EnergyBulletLoop:
.db 4,2,1
.dw ObjectExplodeLoopCel0
.dw ObjectExplodeLoopCel1
.db CHR_STATUS
.db CHR_STATUS

;-----------------------------------------------------------------------------

NPCLoop:
.db 1,8,2
.dw NPCLoopCel0
.dw NPCLoopCel1
.dw NPCLoopCel2
.dw NPCLoopCel3
.dw NPCLoopCel4
.dw NPCLoopCel0
.dw NPCLoopCel1
.dw NPCLoopCel2
.db CHR_NPCSPR
.db CHR_NPCSPR
.db CHR_NPCSPR
.db CHR_NPCSPR
.db CHR_NPCSPR
.db CHR_NPCSPR+1
.db CHR_NPCSPR+1
.db CHR_NPCSPR+1

; gang leader (0)
; tech dude (5)
NPCLoopCel0:
.db 6
.db -24,$81,2,-8
.db -24,$83,2,0
.db -8,$85,2,-8
.db -8,$87,2,0
.db 8,$89,2,-8
.db 8,$8B,2,0
; mystery man (1)
; librarian (6)
NPCLoopCel1:
.db 6
.db -24,$8D,2,-8
.db -24,$8F,2,0
.db -8,$91,2,-8
.db -8,$93,2,0
.db 8,$95,2,-8
.db 8,$97,2,0
; hunched gang member (2)
; tech nerd (7)
NPCLoopCel2:
.db 6
.db -24,$99,2,-8
.db -24,$9B,2,0
.db -8,$9D,2,-8
.db -8,$9F,2,0
.db 8,$A1,2,-8
.db 8,$A3,2,0
; chick
NPCLoopCel3:
.db 6
.db -24,$A5,2,-8
.db -24,$A7,2,0
.db -8,$A9,2,-8
.db -8,$AB,2,0
.db 8,$AD,2,-8
.db 8,$AF,2,0
; old man
NPCLoopCel4:
.db 6
.db -24,$B1,2,-8
.db -24,$B3,2,0
.db -8,$B5,2,-8
.db -8,$B7,2,0
.db 8,$B9,2,-8
.db 8,$BB,2,0

;-----------------------------------------------------------------------------

ItemLoop:
.db 1,16,3
.dw ItemLoopCel0
.dw ItemLoopCel1
.dw ItemLoopCel2
.dw ItemLoopCel3
.dw ItemLoopCel4
.dw ItemLoopCel5
.dw ItemLoopCel6
.dw ItemLoopCel7
.dw ItemLoopCel8
.dw ItemLoopCel9
.dw ItemLoopCel10
.dw ItemLoopCel11
.dw ItemLoopCel12
.dw ItemLoopCel13
.dw ItemLoopCel14
.dw ItemLoopCel15
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR
.db CHR_ITEMSPR

ItemLoopCel0:
.db 2
.db -8,$C1,3,-8
.db -8,$C3,3,0
ItemLoopCel1:
.db 2
.db -8,$C5,3,-8
.db -8,$C7,3,0
ItemLoopCel2:
.db 2
.db -8,$C9,3,-8
.db -8,$CB,3,0
ItemLoopCel3:
.db 2
.db -8,$CD,3,-8
.db -8,$CF,3,0
ItemLoopCel4:
.db 2
.db -8,$D1,3,-8
.db -8,$D3,3,0
ItemLoopCel5:
.db 2
.db -8,$D5,3,-8
.db -8,$D7,3,0
ItemLoopCel6:
.db 2
.db -8,$D9,3,-8
.db -8,$DB,3,0
ItemLoopCel7:
.db 2
.db -8,$DD,3,-8
.db -8,$DF,3,0
ItemLoopCel8:
.db 2
.db -8,$E1,3,-8
.db -8,$E3,3,0
ItemLoopCel9:
.db 2
.db -8,$E5,3,-8
.db -8,$E7,3,0
ItemLoopCel10:
.db 2
.db -8,$E9,3,-8
.db -8,$EB,3,0
ItemLoopCel11:
.db 2
.db -8,$ED,3,-8
.db -8,$EF,3,0
ItemLoopCel12:
.db 2
.db -8,$E1,3,-8
.db -8,$E3,3,0
ItemLoopCel13:
.db 2
.db -8,$E5,3,-8
.db -8,$E7,3,0
ItemLoopCel14:
.db 2
.db -8,$E9,3,-8
.db -8,$EB,3,0
ItemLoopCel15:
.db 2
.db -8,$ED,3,-8
.db -8,$EF,3,0

;-----------------------------------------------------------------------------

NeoDoorLoop:
.db 1,1,3

;-----------------------------------------------------------------------------

BlockingDoorLoop:
.db 6,16,3
.dw BlockingDoorLoopCel0
.dw BlockingDoorLoopCel1
.dw BlockingDoorLoopCel2
.dw BlockingDoorLoopCel3
.dw BlockingDoorLoopCel4
.dw BlockingDoorLoopCel5
.dw BlockingDoorLoopCel6
.dw BlockingDoorLoopCel7
.dw BlockingDoorLoopCel8
.dw BlockingDoorLoopCel9
.dw BlockingDoorLoopCel10
.dw BlockingDoorLoopCel11
.dw BlockingDoorLoopCel12
.dw BlockingDoorLoopCel13
.dw BlockingDoorLoopCel14
.dw BlockingDoorLoopCel15
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1
.db CHR_BOSS0+1

BlockingDoorLoopCel0:
.db 1
.db -32,$C1,3,-4
BlockingDoorLoopCel1:
.db 1
.db -32,$C3,3,-4
BlockingDoorLoopCel2:
.db 1
.db -32,$C5,3,-4
BlockingDoorLoopCel3:
.db 1
.db -32,$C7,3,-4
BlockingDoorLoopCel4:
.db 2
.db -32,$C7,3,-4
.db -16,$C1,3,-4
BlockingDoorLoopCel5:
.db 2
.db -32,$C7,3,-4
.db -16,$C3,3,-4
BlockingDoorLoopCel6:
.db 2
.db -32,$C7,3,-4
.db -16,$C5,3,-4
BlockingDoorLoopCel7:
.db 2
.db -32,$C7,3,-4
.db -16,$C7,3,-4
BlockingDoorLoopCel8:
.db 3
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C1,3,-4
BlockingDoorLoopCel9:
.db 3
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C3,3,-4
BlockingDoorLoopCel10:
.db 3
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C5,3,-4
BlockingDoorLoopCel11:
.db 3
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C7,3,-4
BlockingDoorLoopCel12:
.db 4
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C7,3,-4
.db 16,$C1,3,-4
BlockingDoorLoopCel13:
.db 4
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C7,3,-4
.db 16,$C3,3,-4
BlockingDoorLoopCel14:
.db 4
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C7,3,-4
.db 16,$C5,3,-4
BlockingDoorLoopCel15:
.db 4
.db -32,$C7,3,-4
.db -16,$C7,3,-4
.db 0,$C7,3,-4
.db 16,$C7,3,-4

.end
