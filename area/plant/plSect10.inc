plant_sect10_room0:
.db $02,$02,$02,$02,$02,$02,$02,$02
.db $1B,$1B,$7C,$39,$79,$39,$7C,$39
.db $1B,$1B,$7C,$7D,$7D,$7D,$7C,$7D
.db $1B,$1B,$7C,$4B,$4B,$4B,$7C,$4B
.db $1B,$1B,$6C,$6E,$6E,$6E,$6C,$6E
.db $1B,$1B,$72,$73,$73,$73,$72,$73
.db $1B,$1B,$72,$73,$73,$73,$72,$73
.db $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B
; plant_sect10_room0_objects:
.db $FF
plant_sect10_room1:
.db $02,$02,$02,$02,$02,$02,$02,$02
.db $79,$39,$7C,$0F,$10,$11,$1B,$1B
.db $7D,$7D,$7C,$00,$00,$12,$1B,$1B
.db $4B,$4B,$7C,$00,$00,$00,$1B,$1B
.db $6E,$6E,$6C,$6E,$6E,$6F,$1B,$1B
.db $73,$73,$72,$73,$1C,$74,$1B,$1B
.db $73,$73,$72,$73,$1D,$74,$1B,$1B
.db $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B
; plant_sect10_room1_objects:
.db $02,$C9,$20,$12,$FF
plant_sect10_map:
.dw plant_sect10_room0,plant_sect10_room1
plant_sect10_warps:
.db $01, $C9 ; 00
