.ifndef HUFF_H
.define HUFF_H

; Decoder state is in Scratch.Huff (engine/scratch.h).
.include "engine/scratch.h"

; Exported symbols.
.extrn HuffInit:proc
.extrn HuffDecodeByte:proc

.endif
