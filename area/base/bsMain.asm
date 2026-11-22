.include "engine/anim.h"
.include "chr/chr.h"
.include "engine/coll.h"
.include "game.h"
.include "engine/gbAction.h"
.include "engine/obj.h"
.include "sound/rnme.h"
.include "area/base/base.h"
.include "engine/area2d.h"
.include "engine/bgcollision.h"
.include "engine/enemy.h"
.include "game/flags.h"
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

.public base_maps
.public base_macroptrtable
.public base_macroattribs
.public base_macrowalkabilities
.public base_palette
.public base_objconstructors
.public base_actionptrtable
.public base_loopptrtable

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
