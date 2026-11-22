.ifndef ENEMY_H
.define ENEMY_H

; Exported symbols.
.extrn RND:proc
.extrn TestProjectileCollide:proc
.extrn CheckPlayerHit:proc
.extrn CheckEnemyHit:proc
.extrn IsPlayerHitAndWoundable:proc
.extrn HurtPlayer:proc
.extrn SetAnimWaitAction:proc
.extrn SetExplodeAnim:proc
.extrn LoadBlockingDoor:proc
.extrn TestPlayerCollide:proc
.extrn ExplodeProjectile2:proc
.extrn LoadObjectsFromQueue:proc

.endif  ; !ENEMY_H
