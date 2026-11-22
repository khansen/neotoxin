.ifndef GBLOOP_H
.define GBLOOP_H

LOOP_PLAYERSTAND        EQU 0
LOOP_PLAYERRUN          EQU 1
LOOP_PLAYERJUMP         EQU 2
LOOP_PLAYERDUCK         EQU 3
LOOP_PLAYERCLIMB        EQU 4
LOOP_PLAYERDEAD         EQU 5
LOOP_OBJECTEXPLODE      EQU 6
LOOP_OBJECTBIGEXPLODE   EQU 7
LOOP_HEALTHITEM         EQU 8
LOOP_ROCKET             EQU 9
LOOP_ENERGYBULLET       EQU 10
LOOP_NPC                EQU 11
LOOP_ITEM               EQU 12
LOOP_NEODOOR            EQU 13
LOOP_BLOCKINGDOOR       EQU 14

; Exported symbols.
.extrn PlayerStandLoop:label
.extrn PlayerRunLoop:label
.extrn PlayerJumpLoop:label
.extrn PlayerDuckLoop:label
.extrn PlayerClimbLoop:label
.extrn PlayerDeadLoop:label
.extrn ObjectExplodeLoop:label
.extrn ObjectBigExplodeLoop:label
.extrn HealthItemLoop:label
.extrn RocketLoop:label
.extrn EnergyBulletLoop:label
.extrn NPCLoop:label
.extrn ItemLoop:label
.extrn NeoDoorLoop:label
.extrn BlockingDoorLoop:label

.endif
