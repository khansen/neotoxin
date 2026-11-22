building_sect17_warps:
.db $10,$AB,$00

building_sect17_room0:
.db $4C,$73,$72,$73,$72,$73,$72,$73
.db $4C,$76,$76,$76,$76,$76,$76,$76
.db $4C,$79,$4A,$38,$00,$4A,$53,$38
.db $71,$79,$44,$37,$00,$44,$7F,$37
.db $4C,$79,$44,$37,$00,$44,$7F,$37
.db $4C,$3C,$3C,$3C,$3C,$44,$7F,$3C
.db $4C,$79,$4A,$38,$00,$44,$7F,$38
.db $71,$79,$44,$37,$00,$44,$7F,$37
building_sect17_room0_objects:
.db $FF
building_sect17_room1:
.db $72,$73,$72,$73,$72,$73,$72,$4C
.db $76,$76,$76,$76,$76,$76,$76,$4C
.db $00,$4A,$53,$38,$00,$4A,$53,$4C
.db $00,$44,$7F,$37,$00,$44,$7F,$71
.db $00,$44,$7F,$37,$00,$44,$7F,$4C
.db $00,$44,$3C,$3C,$00,$44,$7F,$4C
.db $00,$44,$53,$38,$00,$44,$7F,$4C
.db $00,$44,$7F,$37,$00,$3C,$3C,$71
building_sect17_room1_objects:
.db $FF
building_sect17_room2:
.db $4C,$79,$44,$37,$00,$44,$7F,$37
.db $4C,$79,$44,$37,$00,$3C,$3C,$3C
.db $4C,$79,$44,$37,$4A,$0D,$0D,$38
.db $71,$3C,$3C,$3C,$36,$36,$36,$39
.db $4C,$35,$35,$38,$33,$0B,$33,$37
.db $4C,$36,$36,$39,$36,$0C,$36,$39
.db $4C,$3E,$3E,$3E,$3E,$3E,$3E,$3E
.db $4C,$6F,$6F,$6F,$6F,$6F,$6F,$6F
building_sect17_room2_objects:
.db $02,$AB,$00,$0B
.db $FF
building_sect17_room3:
.db $00,$7F,$7F,$37,$00,$53,$53,$4C
.db $00,$7F,$3C,$3C,$00,$7F,$7F,$4C
.db $4A,$0D,$0D,$38,$4A,$0D,$0D,$4C
.db $36,$36,$36,$39,$36,$36,$36,$71
.db $33,$33,$33,$37,$33,$33,$33,$4C
.db $36,$36,$36,$39,$36,$36,$36,$4C
.db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$4C
.db $6F,$6F,$6F,$6F,$6F,$6F,$6F,$4C
building_sect17_room3_objects:
.db $FF
building_sect17_map:
.dw building_sect17_room0,building_sect17_room1,building_sect17_room2,building_sect17_room3
