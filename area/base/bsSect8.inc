base_sect8_room0:
.db $2A,$4C,$4C,$4C,$4C,$15,$15,$4C
.db $2A,$20,$20,$20,$20,$20,$20,$20
.db $3C,$1B,$5E,$1B,$5E,$1B,$5E,$1B
.db $2A,$5F,$5E,$5F,$5E,$5F,$5E,$5F
.db $2A,$76,$5E,$76,$01,$76,$5E,$76
.db $3C,$5F,$5E,$5F,$02,$5F,$5E,$5F
.db $2A,$06,$06,$07,$06,$06,$07,$06
.db $2A,$00,$08,$00,$08,$00,$08,$00
; base_sect8_room0_objects:
.db $02,$A9,$40,$0A,$FF
base_sect8_room1:
.db $4C,$15,$15,$4C,$4C,$4C,$4C,$2A
.db $20,$20,$20,$20,$20,$20,$20,$2A
.db $5E,$1B,$5E,$1B,$5E,$1B,$5E,$3C
.db $5E,$5F,$5E,$5F,$5E,$5F,$5E,$2A
.db $5E,$76,$5E,$76,$5E,$76,$5E,$2A
.db $5E,$5F,$5E,$5F,$5E,$5F,$5E,$3C
.db $06,$07,$06,$06,$07,$06,$06,$2A
.db $08,$00,$08,$00,$08,$00,$08,$2A
; base_sect8_room1_objects:
.db $FF
base_sect8_map:
.dw base_sect8_room0,base_sect8_room1
base_sect8_warps:
.db $00, $A9 ; 00
