building_sect2_warps:
.db $10,$AF

building_sect2_room0:
.db $43,$47,$47,$47,$47,$47,$47,$47
.db $43,$56,$56,$56,$56,$56,$56,$56
.db $43,$5A,$5A,$5A,$4A,$53,$53,$53
.db $71,$4F,$59,$4F,$4A,$44,$7F,$2C
.db $45,$59,$59,$59,$4A,$4A,$7F,$2C
.db $43,$4F,$59,$4F,$4A,$7F,$3F,$3F
.db $43,$59,$59,$59,$4A,$44,$53,$53
.db $71,$19,$19,$19,$4A,$4A,$7F,$5D
building_sect2_room0_objects:
.db $04,$D4
.db $FF
building_sect2_room1:
.db $47,$47,$47,$47,$47,$47,$47,$43
.db $56,$56,$56,$56,$56,$56,$56,$43
.db $53,$53,$53,$53,$5A,$5A,$5A,$43
.db $2C,$7F,$44,$4A,$4F,$59,$4F,$71
.db $2C,$7F,$4A,$4A,$59,$59,$59,$45
.db $3F,$3F,$44,$4A,$4F,$59,$4F,$43
.db $53,$53,$44,$4A,$59,$59,$59,$43
.db $5F,$7F,$4A,$4A,$19,$19,$19,$71
building_sect2_room1_objects:
.db $04,$DA,$04,$90
.db $FF
building_sect2_room2:
.db $45,$5A,$5A,$5A,$4A,$44,$4A,$60
.db $43,$4F,$59,$4F,$4A,$3F,$7F,$62
.db $43,$59,$59,$59,$4A,$53,$7F,$2C
.db $71,$19,$19,$19,$4A,$7F,$7F,$2C
.db $45,$4F,$5A,$4F,$4A,$44,$7F,$0B
.db $43,$59,$59,$59,$4A,$0D,$0D,$0C
.db $43,$3C,$3C,$3C,$3C,$3C,$3C,$3C
.db $43,$00,$00,$1E,$00,$00,$1E,$00
building_sect2_room2_objects:
.db $02,$AF,$00,$13,$04,$BA,$04,$1B
.db $FF
building_sect2_room3:
.db $61,$7F,$44,$4A,$5A,$5A,$5A,$45
.db $64,$7F,$3F,$4A,$4F,$59,$4F,$43
.db $2C,$7F,$53,$4A,$59,$59,$59,$43
.db $2C,$7F,$44,$4A,$19,$19,$19,$71
.db $2C,$7F,$44,$4A,$4F,$5A,$4F,$45
.db $0D,$0D,$0D,$4A,$59,$59,$59,$43
.db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$43
.db $00,$1E,$00,$00,$1E,$00,$00,$43
building_sect2_room3_objects:
.db $04,$B4
.db $FF
building_sect2_map:
.dw building_sect2_room0,building_sect2_room1,building_sect2_room2,building_sect2_room3
