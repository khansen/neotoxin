plant_sect7_room0:
.db $14,$37,$37,$2C,$2C,$37,$37,$14
.db $14,$2B,$2B,$2B,$2B,$2B,$2B,$14
.db $14,$15,$00,$7C,$7C,$00,$15,$14
.db $14,$7F,$00,$7C,$7C,$00,$7F,$14
.db $14,$7F,$00,$2A,$2A,$2A,$2A,$14
.db $14,$7F,$00,$7C,$7C,$00,$7F,$14
.db $14,$7F,$00,$7C,$7C,$00,$7F,$14
.db $14,$7F,$15,$7C,$7C,$15,$7F,$14
; plant_sect7_room0_objects:
.db $FF
plant_sect7_room1:
.db $14,$7F,$1A,$7C,$7C,$1A,$7F,$14
.db $14,$7F,$4B,$7C,$7C,$4B,$7F,$14
.db $14,$7F,$4C,$7C,$7C,$4C,$7F,$14
.db $14,$67,$66,$67,$67,$66,$67,$14
.db $14,$68,$68,$1C,$68,$68,$68,$14
.db $14,$63,$48,$1D,$63,$4A,$63,$14
.db $14,$2A,$2A,$2A,$2A,$2A,$2A,$14
.db $14,$7C,$1B,$7C,$7C,$1B,$7C,$14
; plant_sect7_room1_objects:
.db $02,$A7,$20,$0E,$FF
plant_sect7_map:
.dw plant_sect7_room0,plant_sect7_room1
plant_sect7_warps:
.db $10, $A7 ; 00
