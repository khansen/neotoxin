plant_sect3_room0:
.db $14,$14,$14,$14,$14,$14,$14,$14
.db $00,$3E,$00,$37,$27,$26,$26,$26
.db $0F,$3E,$0F,$37,$0F,$0F,$0F,$0F
.db $3B,$3E,$3B,$3B,$3B,$3B,$3B,$3B
.db $3B,$3E,$3B,$13,$3B,$1C,$3B,$13
.db $3B,$3E,$3B,$3C,$3B,$1D,$3B,$3C
.db $29,$29,$29,$29,$29,$29,$29,$29
.db $21,$4D,$4D,$22,$21,$4D,$4D,$22
; plant_sect3_room0_objects:
.db $02,$AB,$20,$06,$FF
plant_sect3_room1:
.db $14,$14,$14,$14,$14,$14,$14,$14
.db $26,$28,$37,$27,$26,$26,$26,$3E
.db $0F,$0F,$37,$0F,$0F,$6C,$6E,$3E
.db $3B,$3B,$3B,$3B,$3B,$5A,$5B,$3E
.db $3B,$3B,$13,$3B,$3B,$2C,$2C,$3E
.db $3B,$3B,$3C,$3B,$3B,$6C,$6E,$3E
.db $29,$29,$29,$29,$29,$29,$29,$29
.db $21,$4D,$4D,$22,$21,$4D,$4D,$22
; plant_sect3_room1_objects:
.db $FF
plant_sect3_map:
.dw plant_sect3_room0,plant_sect3_room1
plant_sect3_warps:
.db $00, $AB ; 00
