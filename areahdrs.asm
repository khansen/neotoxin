.include "chr.h"

.codeseg

.public AreaHdrTable

.extrn ruins_maps:label
.extrn ruins_macroptrtable:label
.extrn ruins_macroattribs:label
.extrn ruins_macrowalkabilities:label
.extrn ruins_palette:label
.extrn ruins_objconstructors:label
.extrn ruins_actionptrtable:label
.extrn ruins_loopptrtable:label
.extrn plant_maps:label
.extrn plant_macroptrtable:label
.extrn plant_macroattribs:label
.extrn plant_macrowalkabilities:label
.extrn plant_palette:label
.extrn plant_objconstructors:label
.extrn plant_actionptrtable:label
.extrn plant_loopptrtable:label
.extrn base_maps:label
.extrn base_macroptrtable:label
.extrn base_macroattribs:label
.extrn base_macrowalkabilities:label
.extrn base_palette:label
.extrn base_objconstructors:label
.extrn base_actionptrtable:label
.extrn base_loopptrtable:label
.extrn building_maps:label
.extrn building_macroptrtable:label
.extrn building_macroattribs:label
.extrn building_macrowalkabilities:label
.extrn building_palette:label
.extrn building_objconstructors:label
.extrn building_actionptrtable:label
.extrn building_loopptrtable:label
.extrn boss0_maps:label
.extrn boss0_macroptrtable:label
.extrn boss0_macroattribs:label
.extrn boss0_macrowalkabilities:label
.extrn boss0_palette:label
.extrn boss0_objconstructors:label
.extrn boss0_actionptrtable:label
.extrn boss0_loopptrtable:label
.extrn boss1_maps:label
.extrn boss1_macroptrtable:label
.extrn boss1_macroattribs:label
.extrn boss1_macrowalkabilities:label
.extrn boss1_palette:label
.extrn boss1_objconstructors:label
.extrn boss1_actionptrtable:label
.extrn boss1_loopptrtable:label
.extrn boss2_maps:label
.extrn boss2_macroptrtable:label
.extrn boss2_macroattribs:label
.extrn boss2_macrowalkabilities:label
.extrn boss2_palette:label
.extrn boss2_objconstructors:label
.extrn boss2_actionptrtable:label
.extrn boss2_loopptrtable:label

;-------------------------------[ Area headers ]------------------------------

AreaHdrTable:
.dw ruins_header
;.dw city_header
.dw plant_header
.dw base_header
.dw building_header
.dw boss0_header
.dw boss1_header
.dw boss2_header
.dw 0 ; 8th area goes here

ruins_header:
.db 1
.dw ruins_maps
.dw ruins_macroptrtable
.dw ruins_macroattribs
.dw ruins_macrowalkabilities
.dw ruins_palette
.db CHR_RUINS, CHR_RUINS+2
.dw ruins_objconstructors
.dw ruins_actionptrtable
.dw ruins_loopptrtable

;city_header:
;.db 1
;.dw city_maps
;.dw city_macroptrtable
;.dw city_macroattribs
;.dw city_macrowalkabilities
;.dw city_palette
;.db CHR_RUINS, CHR_RUINS+2
;.dw city_objconstructors
;.dw city_actionptrtable
;.dw city_loopptrtable

plant_header:
.db 2
.dw plant_maps
.dw plant_macroptrtable
.dw plant_macroattribs
.dw plant_macrowalkabilities
.dw plant_palette
.db CHR_PLANT, CHR_PLANT+2
.dw plant_objconstructors
.dw plant_actionptrtable
.dw plant_loopptrtable

base_header:
.db 3
.dw base_maps
.dw base_macroptrtable
.dw base_macroattribs
.dw base_macrowalkabilities
.dw base_palette
.db CHR_BASE, CHR_BASE+2
.dw base_objconstructors
.dw base_actionptrtable
.dw base_loopptrtable

building_header:
.db 4
.dw building_maps
.dw building_macroptrtable
.dw building_macroattribs
.dw building_macrowalkabilities
.dw building_palette
.db CHR_BUILDING, CHR_BUILDING+2
.dw building_objconstructors
.dw building_actionptrtable
.dw building_loopptrtable

boss0_header:
.db 4
.dw boss0_maps
.dw boss0_macroptrtable
.dw boss0_macroattribs
.dw boss0_macrowalkabilities
.dw boss0_palette
.db CHR_BOSS0BG, CHR_BOSS0BG+2
.dw boss0_objconstructors
.dw boss0_actionptrtable
.dw boss0_loopptrtable

boss1_header:
.db 4
.dw boss1_maps
.dw boss1_macroptrtable
.dw boss1_macroattribs
.dw boss1_macrowalkabilities
.dw boss1_palette
.db CHR_BOSS1BG, CHR_BOSS1BG+2
.dw boss1_objconstructors
.dw boss1_actionptrtable
.dw boss1_loopptrtable

boss2_header:
.db 4
.dw boss2_maps
.dw boss2_macroptrtable
.dw boss2_macroattribs
.dw boss2_macrowalkabilities
.dw boss2_palette
.db CHR_BOSS2BG, CHR_BOSS2BG+2
.dw boss2_objconstructors
.dw boss2_actionptrtable
.dw boss2_loopptrtable


.end
