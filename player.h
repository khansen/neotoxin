.ifndef PLAYER_H
.define PLAYER_H

OE_PLAYERSTAND      EQU 0
OE_PLAYERRUN        EQU 1
OE_PLAYERJUMP       EQU 2
OE_PLAYERFALL       EQU 3
OE_PLAYERLADDER     EQU 4
OE_PLAYERDUCK       EQU 5
OE_PLAYERDEAD       EQU 6
OE_PLAYERHURT       EQU 7

; Exported symbols.
.extrn PlayerStand:proc
.extrn PlayerRun:proc
.extrn PlayerJump:proc
.extrn PlayerFall:proc
.extrn PlayerLadder:proc
.extrn PlayerDuck:proc
.extrn PlayerDead:proc
.extrn PlayerHurt:proc
.extrn SetStanding:proc
.extrn PlayerStartFall:proc
.extrn PlayerStandUp:proc

.endif
