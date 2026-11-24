.ifndef ATTRIBTABLE_H
.define ATTRIBTABLE_H

; WRAM copies of the attribute tables at $23C0 and $2BC0 (64 bytes each),
; so that a write can change some of a byte's bits and keep the others.
ATTRIB_BUFFER           EQU     $7000

; Exported symbols.
.extrn HSGE_WriteAttribTableCol:proc
.extrn HSGE_WriteAttribTableRow:proc

.endif  ; !ATTRIBTABLE_H
