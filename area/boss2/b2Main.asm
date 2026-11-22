.include "engine/anim.h"
.include "game.h"
.include "engine/obj.h"
.include "area/boss2/boss2.h"
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

.public boss2_maps
.public boss2_macroptrtable
.public boss2_macroattribs
.public boss2_macrowalkabilities
.public boss2_palette
.public boss2_objconstructors
.public boss2_actionptrtable
.public boss2_loopptrtable

; "Boss2" - Main source

boss2_palette:
.db $0F,$00,$06,$20
.db $0F,$03,$13,$33
.db $0F,$0C,$1C,$2C
.db $0F,$08,$18,$28
.db $0F,$08,$16,$30
.db $0F,$2B,$1A,$07
.db $0F,$0C,$1A,$30
.db $0F,$00,$10,$20

boss2_maps:
.db 2,2 : .dw boss2_sect0_map, boss2_sect0_warps : .db 10,0
.db 2,1 : .dw boss2_sect1_map, boss2_sect1_warps : .db 10,0

.incsrc "area/boss2/b2Macro.inc"
.incsrc "area/boss2/b2Sect0.inc"
.incsrc "area/boss2/b2Sect1.inc"
.incsrc "area/boss2/b2Obj.inc"
.incsrc "area/boss2/b2Loop.inc"
.incsrc "area/boss2/b2Action.inc"

.end
