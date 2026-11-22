.ifndef SFX_H
.define SFX_H

; Sound effect numbers (entry n-1 of RNME_SFXPtrTable in sound/sfxdata.asm).
SFX_ROCKETLAUNCH    EQU 1
SFX_METAL           EQU 2
SFX_CURSOR          EQU 3   ; menu cursor moved
SFX_KEY             EQU 4   ; name entry: letter typed or erased
SFX_CONFIRM         EQU 5   ; menu choice confirmed; also item pickup
SFX_ROCKETEXPLODE   EQU 6
SFX_PLAYERDIE       EQU 7
SFX_ENEMYEXPLODE    EQU 8
SFX_ENEMYHIT        EQU 9
SFX_LEVELUP         EQU 10
SFX_PLAYERJUMP      EQU 11
SFX_NOISEEXPLODE    EQU 12
SFX_ENERGYBULLET    EQU 13

; Exported symbols.
.extrn PlaySFX:proc
.extrn PlayNoiseSFX:proc

.endif  ; !SFX_H
