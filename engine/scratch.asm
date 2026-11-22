; Description:
; The zero page scratch union declared in engine/scratch.h.

.include "engine/scratch.h"

.public Scratch

.dataseg zeropage

Scratch         .shared_scratch

.end
