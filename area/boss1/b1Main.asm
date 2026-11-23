.include "engine/anim.h"
.include "chr/chr.h"
.include "game.h"
.include "engine/obj.h"
.include "area/boss1/boss1.h"
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
.include "common/nmi.h"

.codeseg

.public boss1_maps
.public boss1_macroptrtable
.public boss1_macroattribs
.public boss1_macrowalkabilities
.public boss1_palette
.public boss1_objconstructors
.public boss1_actionptrtable
.public boss1_loopptrtable

; "Boss1" - Main source

boss1_palette:
.db $0F,$00,$06,$20
.db $0F,$03,$13,$33
.db $0F,$0C,$1C,$2C
.db $0F,$08,$18,$28
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$0C,$1A,$30
.db $0F,$00,$10,$20

boss1_maps:
.db 2,2 : .dw boss1_sect0_map, boss1_sect0_warps : .db 10,0
.db 2,1 : .dw boss1_sect1_map, boss1_sect1_warps : .db 10,0

.incsrc "area/boss1/b1Macro.inc"
.incsrc "area/boss1/b1Sect0.inc"
.incsrc "area/boss1/b1Sect1.inc"
.incsrc "area/boss1/b1Obj.inc"
.incsrc "area/boss1/b1Loop.inc"
.incsrc "area/boss1/b1Action.inc"

.end
