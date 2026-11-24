.ifndef WARP_H
.define WARP_H

; In WRAM: the player's direction (OBJ_State bit 0) across a warp.
WarpDirection           EQU     $7FFF

; Exported symbols.
.extrn AreaStartX:byte
.extrn AreaStartY:byte
.extrn PlayerStart:byte
.extrn MapWidth:byte
.extrn MapHeight:byte
.extrn pMap:word
.extrn SetSavePtr:proc
.extrn SetupWarp:proc
.extrn ExecWarp:proc
.extrn Load2DArea:proc

.endif  ; !WARP_H
