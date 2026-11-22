building_sect22_room0:
.db $1D,$18,$7C,$4A,$7B,$18,$18,$18
.db $1D,$56,$56,$56,$56,$56,$30,$31
.db $1D,$00,$05,$00,$00,$00,$6D,$70
.db $1D,$6F,$0C,$6F,$6F,$6F,$6E,$4D
.db $1D,$30,$14,$14,$14,$31,$30,$14
.db $1D,$7A,$15,$15,$7A,$15,$15,$7A
.db $1D,$10,$7C,$10,$10,$10,$7B,$10
.db $1D,$18,$18,$10,$7C,$18,$4A,$10
building_sect22_room0_objects:
.db $02,$65,$81,$01
.db $FF
building_sect22_room1:
.db $7C,$4A,$4A,$4A,$7C,$18,$18,$18
.db $30,$14,$14,$31,$30,$14,$14,$31
.db $00,$00,$6F,$6D,$6C,$6E,$67,$67
.db $6F,$6E,$4D,$70,$6E,$4D,$67,$67
.db $14,$31,$30,$14,$14,$31,$30,$14
.db $00,$00,$00,$00,$15,$7A,$15,$15
.db $4A,$15,$00,$4A,$10,$10,$7B,$10
.db $15,$10,$4A,$7A,$10,$10,$7A,$10
building_sect22_room1_objects:
.db $FF
building_sect22_room2:
.db $18,$7C,$4A,$4A,$7C,$18,$18,$18
.db $30,$14,$14,$14,$31,$1D,$30,$14
.db $6C,$00,$4A,$00,$4A,$1D,$4A,$00
.db $70,$4A,$44,$00,$44,$1D,$44,$00
.db $14,$31,$2C,$4A,$2C,$1D,$7F,$00
.db $15,$15,$2C,$4A,$2C,$1D,$07,$00
.db $7C,$10,$2C,$44,$19,$3D,$19,$7E
.db $10,$10,$2C,$2C,$44,$44,$44,$4A
building_sect22_room2_objects:
.db $FF
building_sect22_room3:
.db $18,$7C,$18,$4A,$4A,$7B,$18,$1D
.db $14,$14,$14,$14,$14,$14,$31,$1D
.db $00,$00,$4A,$00,$00,$4A,$00,$1D
.db $00,$00,$44,$00,$00,$44,$00,$1D
.db $19,$19,$19,$7E,$7D,$2C,$7E,$1D
.db $00,$15,$7F,$00,$00,$7F,$00,$1D
.db $7D,$10,$7F,$7E,$7D,$07,$7E,$1D
.db $00,$10,$07,$00,$00,$19,$19,$1D
building_sect22_room3_objects:
.db $FF
building_sect22_room4:
.db $1D,$4A,$4A,$10,$10,$4A,$4A,$10
.db $1D,$44,$44,$18,$18,$44,$44,$10
.db $1D,$2C,$2C,$1D,$1D,$2C,$2C,$18
.db $1D,$3D,$3D,$3D,$3D,$3D,$3D,$3D
.db $1D,$6E,$6C,$67,$70,$67,$70,$00
.db $1D,$6A,$70,$67,$69,$67,$4E,$6C
.db $1D,$19,$19,$19,$19,$19,$19,$19
.db $1D,$00,$1E,$00,$1E,$00,$1E,$00
building_sect22_room4_objects:
.db $04,$BE,0
.db $05,$A4,<NPC6Script,>NPC6Script,$06
.db $FF
building_sect22_room5:
.db $18,$18,$7A,$18,$18,$10,$18,$18
.db $3D,$3D,$18,$3D,$3D,$18,$3D,$3D
.db $4A,$4A,$3D,$44,$44,$3D,$44,$4A
.db $4A,$44,$44,$2C,$2C,$44,$02,$44
.db $4A,$0D,$0D,$0D,$0D,$0D,$0D,$0D
.db $0E,$3F,$3F,$3F,$3F,$3F,$3F,$3F
.db $00,$78,$79,$78,$74,$79,$78,$79
.db $00,$73,$72,$73,$4D,$72,$73,$72
building_sect22_room5_objects:
.db $FF
building_sect22_room6:
.db $7C,$10,$0D,$0D,$0D,$0D,$0D,$7E
.db $3D,$10,$30,$31,$30,$31,$30,$31
.db $00,$1D,$56,$56,$56,$56,$56,$56
.db $4A,$00,$00,$6F,$00,$00,$00,$6F
.db $4A,$00,$6E,$4D,$70,$6F,$6E,$4D
.db $0F,$6D,$4D,$4D,$4D,$4F,$4D,$4D
.db $00,$41,$41,$41,$41,$41,$41,$41
.db $00,$1E,$00,$1E,$00,$1E,$00,$1E
building_sect22_room6_objects:
.db $FF
building_sect22_room7:
.db $7D,$10,$7F,$7E,$7D,$7F,$7E,$1D
.db $30,$10,$19,$00,$00,$07,$17,$1D
.db $56,$1D,$7E,$7D,$7D,$7F,$16,$1D
.db $00,$6F,$00,$00,$0E,$19,$19,$1D
.db $70,$6A,$6C,$0E,$00,$00,$6F,$1D
.db $4E,$70,$0E,$00,$6F,$6E,$4D,$1D
.db $41,$41,$41,$41,$41,$41,$41,$1D
.db $00,$1E,$00,$1E,$00,$1E,$00,$1D
building_sect22_room7_objects:
.db $FF
building_sect22_map:
.dw building_sect22_room0,building_sect22_room1,building_sect22_room2,building_sect22_room3
.dw building_sect22_room4,building_sect22_room5,building_sect22_room6,building_sect22_room7
building_sect22_warps:
.db $10, $A6
.db $00, $65
