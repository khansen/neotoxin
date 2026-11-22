.include "engine/anim.h"
.include "chr/chr.h"
.include "engine/coll.h"
.include "game.h"
.include "engine/obj.h"
.include "area/ruins/ruins.h"
.include "engine/area2d.h"
.include "engine/bgcollision.h"
.include "engine/enemy.h"
.include "game/flags.h"
.include "engine/gbAction.h"
.include "engine/gbLoop.h"
.include "engine/gbObj.h"
.include "game/maincycle.h"
.include "common/math.h"
.include "engine/movement.h"
.include "engine/ngsl.h"
.include "engine/objcollision.h"
.include "engine/player.h"
.include "common/ppu.h"

.codeseg

.public ruins_maps
.public ruins_macroptrtable
.public ruins_macroattribs
.public ruins_macrowalkabilities
.public ruins_palette
.public ruins_objconstructors
.public ruins_actionptrtable
.public ruins_loopptrtable

; "Ruins" - Main source

ruins_palette:
.db $0F,$0C,$00,$10
.db $0F,$07,$16,$27
.db $0F,$07,$00,$2C
.db $0F,$01,$12,$21
.db $0F,$08,$16,$30
.db $0F,$2A,$16,$0F
.db $0F,$0C,$13,$1A
.db $0F,$03,$14,$27

.incsrc "area/ruins/rnMacro.inc"
.incsrc "area/ruins/rnMaps.inc"
.incsrc "area/ruins/rnObj.inc"
.incsrc "area/ruins/rnAction.inc"
.incsrc "area/ruins/rnLoop.inc"

.end
