.include "area.h"

.codeseg

.public building_maps
.public building_macroptrtable
.public building_macroattribs
.public building_macrowalkabilities
.public building_palette
.public building_objconstructors
.public building_actionptrtable
.public building_loopptrtable

; "Building" - Main source

building_palette:
.db $0F,$0C,$00,$21
.db $0F,$07,$16,$27
.db $0F,$08,$01,$11
.db $0F,$08,$0C,$1C
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$01,$11,$31
.db $0F,$00,$11,$31

.incsrc "area/building/bdMacro.inc"
.incsrc "area/building/bdMaps.inc"
.incsrc "area/building/bdObj.inc"
.incsrc "area/building/bdLoop.inc"
.incsrc "area/building/bdAction.inc"

.end
