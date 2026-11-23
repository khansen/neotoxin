.ifndef WARP_H
.define WARP_H

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
