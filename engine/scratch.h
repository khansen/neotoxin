.ifndef SCRATCH_H
.define SCRATCH_H

; Zero page scratch shared by three modules that never run at the same time:
; object collision checks (Area2D), Huffman text decoding (scripts) and the
; VSTE credits scroller. Scratch is a single allocation; each module uses its
; own member of the union, through the names below.

MAX_COLLISIONS          EQU     8       ; objects recorded per collision check

.struc coll_scratch
OBJ2_Left               .byte
OBJ2_Top                .byte
OBJ2_Right              .byte
OBJ2_Bottom             .byte
CollObjCount            .byte
CollObjNums             .byte[MAX_COLLISIONS]
CollObjTypes            .byte[MAX_COLLISIONS]
.ends

.struc huff_scratch
pHuffNode               .word
pHuffData               .word
HuffCount               .byte
HuffInput               .byte
.ends

.struc vste_scratch
pScrollPPU              .word
pScroller               .word
pAttribPPU              .word
pWorkPPU                .word
.ends

.union shared_scratch
Coll                    .coll_scratch
Huff                    .huff_scratch
Vste                    .vste_scratch
.ends

.extrn Scratch:shared_scratch   ; engine/scratch.asm

OBJ2_Left               EQU     Scratch.Coll.OBJ2_Left
OBJ2_Top                EQU     Scratch.Coll.OBJ2_Top
OBJ2_Right              EQU     Scratch.Coll.OBJ2_Right
OBJ2_Bottom             EQU     Scratch.Coll.OBJ2_Bottom
CollObjCount            EQU     Scratch.Coll.CollObjCount
CollObjNums             EQU     Scratch.Coll.CollObjNums
CollObjTypes            EQU     Scratch.Coll.CollObjTypes

pHuffNode               EQU     Scratch.Huff.pHuffNode
pHuffData               EQU     Scratch.Huff.pHuffData
HuffCount               EQU     Scratch.Huff.HuffCount
HuffInput               EQU     Scratch.Huff.HuffInput

pScrollPPU              EQU     Scratch.Vste.pScrollPPU
pScroller               EQU     Scratch.Vste.pScroller
pAttribPPU              EQU     Scratch.Vste.pAttribPPU
pWorkPPU                EQU     Scratch.Vste.pWorkPPU

.endif  ; !SCRATCH_H
