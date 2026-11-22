.ifndef GBACTION_H
.define GBACTION_H

OE_PROJECTILEMAIN   EQU 8
OE_MANUALWARPMAIN   EQU 9
OE_INSTANTWARPMAIN  EQU 10
OE_ITEMMAIN         EQU 11
OE_NPCMAIN          EQU 12
OE_NEODOORMAIN      EQU 13
OE_BLOCKINGDOORMAIN EQU 14
OE_DISCARDOBJECT    EQU 15
OE_IDLE             EQU 16
OE_HEALTHITEMMAIN   EQU 17
OE_WAITANIMEND      EQU 18
OE_DISCARDENEMY     EQU 19

; Exported symbols.
.extrn ProjectileMain:proc
.extrn ManualWarpMain:proc
.extrn InstantWarpMain:proc
.extrn ItemMain:proc
.extrn NPCMain:proc
.extrn NeoDoorMain:proc
.extrn BlockingDoorMain:proc
.extrn HealthItemMain:proc
.extrn WaitAnimEnd:proc
.extrn DiscardEnemy:proc
.extrn EnemyMain:proc
.extrn CheckHealthItemBounce:proc
.extrn ProgramControl:proc
.extrn PlayerControl:proc
.extrn ExplodeProjectile:proc

.endif
