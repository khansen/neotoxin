building_sect16_warps:
.db $01,$C3

building_sect16_room0:
.db $3A,$3A,$3A,$3A,$3A,$3A,$3A,$3A
.db $3A,$3D,$3D,$3D,$3D,$3D,$3D,$3D
.db $71,$00,$4A,$38,$00,$4A,$7F,$38
.db $3A,$00,$7F,$37,$00,$7F,$7F,$37
.db $3A,$36,$36,$39,$36,$36,$36,$39
.db $71,$33,$33,$37,$33,$2F,$33,$37
.db $3A,$36,$36,$39,$36,$36,$36,$39
.db $3A,$41,$41,$41,$41,$41,$41,$41
building_sect16_room0_objects:
.db $FF
building_sect16_room1:
.db $3A,$3A,$3A,$3A,$3A,$3A,$3A,$3A
.db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3A
.db $00,$4A,$7F,$38,$00,$4A,$7F,$71
.db $00,$7F,$7F,$37,$00,$7F,$7F,$3A
.db $36,$36,$36,$39,$36,$36,$36,$3A
.db $33,$0B,$33,$37,$33,$1C,$33,$71
.db $36,$0C,$36,$39,$36,$36,$36,$3A
.db $41,$41,$41,$41,$41,$41,$41,$3A
building_sect16_room1_objects:
.db $02,$C3,$00,$0A
.db $FF
building_sect16_map:
.dw building_sect16_room0,building_sect16_room1
