building_sect4_warps:
.db $00,$4F

building_sect4_room0:
.db $3A,$77,$77,$77,$77,$77,$77,$77
.db $3A,$3D,$3D,$3D,$3D,$3D,$3D,$0B
.db $71,$4A,$00,$78,$79,$00,$00,$0C
.db $3A,$44,$4A,$73,$72,$0E,$58,$3E
.db $3A,$44,$4A,$58,$3E,$57,$6F,$6F
.db $71,$4A,$00,$70,$6F,$6E,$69,$67
.db $3A,$6F,$6E,$67,$69,$67,$69,$67
.db $3A,$3C,$3C,$3C,$3C,$3C,$3C,$3C
building_sect4_room0_objects:
.db $02,$4F,$00,$0F
.db $FF
building_sect4_room1:
.db $77,$77,$77,$77,$77,$77,$77,$3A
.db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3A
.db $00,$00,$78,$79,$00,$4A,$44,$71
.db $57,$0F,$73,$72,$00,$4A,$44,$3A
.db $00,$58,$3E,$57,$00,$00,$4A,$3A
.db $70,$6E,$69,$67,$6F,$70,$6F,$71
.db $69,$67,$69,$67,$69,$67,$69,$3A
.db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3A
building_sect4_room1_objects:
.db $FF
building_sect4_map:
.dw building_sect4_room0,building_sect4_room1
