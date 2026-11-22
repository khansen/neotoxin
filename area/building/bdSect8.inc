building_sect8_warps:
.db $01,$C9

building_sect8_room0:
.db $75,$75,$75,$75,$75,$75,$75,$75
.db $75,$56,$56,$56,$56,$56,$56,$56
.db $75,$6E,$6B,$6A,$70,$6F,$6E,$4D
.db $75,$68,$65,$6A,$4D,$4D,$52,$4D
.db $75,$70,$6F,$69,$6B,$6A,$4D,$52
.db $75,$19,$19,$19,$0F,$00,$6A,$4D
.db $75,$70,$6F,$00,$00,$0F,$00,$6A
.db $75,$3C,$3C,$3C,$3C,$3C,$3C,$3C
building_sect8_room0_objects:
.db $FF
building_sect8_room1:
.db $75,$75,$75,$75,$75,$75,$75,$75
.db $56,$56,$56,$56,$56,$56,$56,$75
.db $52,$4D,$4D,$70,$6E,$4D,$69,$75
.db $69,$6B,$6A,$4D,$4D,$52,$6C,$75
.db $66,$68,$65,$52,$4D,$4D,$70,$75
.db $70,$6F,$6E,$4D,$0B,$52,$4D,$75
.db $52,$4D,$69,$6A,$0C,$4D,$69,$75
.db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$75
building_sect8_room1_objects:
.db $02,$C9,$00,$00
.db $FF
building_sect8_map:
.dw building_sect8_room0,building_sect8_room1
