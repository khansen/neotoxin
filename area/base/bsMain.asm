.include "anim.h"
.include "area.h"
.include "chr.h"
.include "coll.h"
.include "game.h"
.include "gbAction.h"
.include "obj.h"
.include "rnme.h"

.codeseg

.public base_maps
.public base_macroptrtable
.public base_macroattribs
.public base_macrowalkabilities
.public base_palette
.public base_objconstructors
.public base_actionptrtable
.public base_loopptrtable

.extrn LOOP_MOVINGFIELD:label

; "Base" - Main source

base_palette:
.db $0F,$0C,$00,$31
.db $0F,$08,$07,$17
.db $0F,$0A,$1C,$2B
.db $0F,$07,$27,$39
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$0C,$22,$28
.db $0F,$0F,$30,$30

.incsrc "area/base/bsMacro.inc"
.incsrc "area/base/bsMaps.inc"
.incsrc "area/base/bsObj.inc"
.incsrc "area/base/bsLoop.inc"
.incsrc "area/base/bsAction.inc"

.end
