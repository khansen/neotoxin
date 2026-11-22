.include "anim.h"
.include "area.h"
.include "chr.h"
.include "coll.h"
.include "game.h"
.include "obj.h"

.codeseg

.public LOOP_MOVINGFIELD
.public plant_maps
.public plant_macroptrtable
.public plant_macroattribs
.public plant_macrowalkabilities
.public plant_palette
.public plant_objconstructors
.public plant_actionptrtable
.public plant_loopptrtable

; "Plant" - Main source

plant_palette:
.db $0F,$0C,$13,$22
.db $0F,$0B,$00,$31
.db $0F,$07,$16,$27
.db $0F,$09,$1C,$2C
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$08,$28,$30
.db $0F,$0F,$30,$30

.incsrc "area/plant/plMacro.inc"
.incsrc "area/plant/plMaps.inc"
.incsrc "area/plant/plObj.inc"
.incsrc "area/plant/plLoop.inc"
.incsrc "area/plant/plAction.inc"

.end
