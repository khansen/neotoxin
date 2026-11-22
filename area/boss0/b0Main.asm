.include "engine/anim.h"
.include "chr/chr.h"
.include "game.h"
.include "engine/obj.h"
.include "engine/player.h"
.include "sound/rnme.h"
.include "area/boss0/boss0.h"
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
.include "common/ppu.h"

.codeseg

.public boss0_maps
.public boss0_macroptrtable
.public boss0_macroattribs
.public boss0_macrowalkabilities
.public boss0_palette
.public boss0_objconstructors
.public boss0_actionptrtable
.public boss0_loopptrtable

; "Boss0" - Main source

boss0_palette:
.db $0F,$08,$03,$12
.db $0F,$0B,$0C,$0F
.db $0F,$0A,$06,$17
.db $0F,$00,$10,$20
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$0C,$1A,$30
.db $0F,$00,$10,$20

boss0_maps:
.db 2,2 : .dw boss0_sect0_map, boss0_sect0_warps : .db 10,0
.db 4,1 : .dw boss0_sect1_map, boss0_sect1_warps : .db 10,0

.incsrc "area/boss0/b0Macro.inc"
.incsrc "area/boss0/b0Sect0.inc"
.incsrc "area/boss0/b0Sect1.inc"
.incsrc "area/boss0/b0Obj.inc"
.incsrc "area/boss0/b0Loop.inc"
.incsrc "area/boss0/b0Action.inc"

.end
