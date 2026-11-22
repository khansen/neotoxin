building_sect20_warps:
.db $20,$AF
.db $01,$C1

building_sect20_room0:
.db $4C,$67,$79,$67,$79,$67,$79,$67
.db $4C,$3D,$3D,$3D,$3D,$3D,$3D,$3D
.db $4C,$70,$00,$00,$00,$6F,$00,$6F
.db $71,$69,$00,$6F,$6E,$69,$00,$6A
.db $4C,$6F,$6E,$4D,$1D,$6D,$70,$00
.db $4C,$6A,$4D,$69,$1D,$6E,$4D,$6C
.db $4C,$19,$6B,$00,$1D,$6A,$4D,$70
.db $71,$6E,$6C,$00,$41,$41,$41,$41
; building_sect20_room0_objects:
.db $FF
building_sect20_room1:
.db $79,$67,$79,$67,$79,$67,$79,$4C
.db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$4C
.db $6E,$70,$00,$00,$00,$6F,$6E,$4C
.db $4D,$69,$6F,$6F,$6E,$4D,$69,$71
.db $6B,$6E,$4D,$4D,$69,$6A,$70,$4C
.db $05,$69,$6A,$69,$0E,$41,$41,$4C
.db $0C,$6E,$69,$0E,$00,$00,$00,$4C
.db $41,$41,$41,$41,$41,$41,$41,$71
; building_sect20_room1_objects:
.db $02,$C1,$00,$03
.db $FF
building_sect20_room2:
.db $4C,$69,$00,$00,$00,$7F,$7F,$00
.db $4C,$00,$29,$2B,$2B,$2E,$2E,$00
.db $4C,$3E,$3E,$3E,$3E,$3E,$3E,$3E
.db $71,$6E,$70,$6F,$00,$6E,$70,$6F
.db $4C,$69,$6B,$6A,$70,$6B,$6B,$6A
.db $4C,$65,$00,$66,$1D,$65,$66,$68
.db $4C,$17,$16,$17,$1D,$16,$17,$16
.db $71,$19,$66,$68,$1D,$68,$65,$66
; building_sect20_room2_objects:
.db $FF
building_sect20_room3:
.db $7F,$00,$07,$00,$4A,$44,$44,$4C
.db $07,$00,$7F,$00,$44,$07,$7F,$4C
.db $1D,$3E,$3E,$1D,$4A,$7F,$7F,$4C
.db $1D,$78,$79,$1D,$4A,$7F,$19,$71
.db $1D,$78,$79,$1D,$4A,$7F,$7F,$4C
.db $1D,$78,$79,$1D,$19,$68,$68,$4C
.db $1D,$78,$79,$1D,$17,$16,$17,$4C
.db $1D,$78,$79,$1D,$68,$68,$19,$71
; building_sect20_room3_objects:
.db $FF
building_sect20_room4:
.db $4C,$6F,$6E,$70,$1D,$53,$07,$53
.db $4C,$69,$6B,$19,$1D,$7F,$7F,$07
.db $4C,$68,$65,$66,$1D,$0D,$0D,$0D
.db $71,$07,$53,$53,$41,$41,$41,$41
.db $4C,$53,$07,$7F,$53,$07,$53,$05
.db $4C,$0D,$0D,$0D,$0D,$0D,$0D,$0C
.db $4C,$42,$42,$42,$42,$42,$42,$42
.db $4C,$00,$50,$00,$50,$00,$50,$00
; building_sect20_room4_objects:
.db $02,$AF,$00,$03
.db $FF
building_sect20_room5:
.db $41,$41,$41,$41,$53,$53,$07,$4C
.db $53,$53,$53,$53,$07,$7F,$7F,$4C
.db $0D,$2E,$2E,$0D,$0D,$0D,$0D,$4C
.db $41,$41,$41,$41,$41,$41,$41,$71
.db $53,$53,$07,$53,$53,$07,$53,$4C
.db $0D,$0D,$2E,$0D,$2E,$2E,$0D,$4C
.db $42,$42,$42,$42,$42,$42,$42,$4C
.db $50,$00,$50,$00,$50,$00,$50,$4C
; building_sect20_room5_objects:
.db $FF
building_sect20_map:
.dw building_sect20_room0,building_sect20_room1,building_sect20_room2,building_sect20_room3
.dw building_sect20_room4,building_sect20_room5
