.ifndef HUFF_H
.define HUFF_H

pHuffNode       EQU     $50
pHuffData       EQU     $52
HuffCount       EQU     $54
HuffInput       EQU     $55

; Exported symbols.
.extrn HuffInit:proc
.extrn HuffDecodeByte:proc

.endif
