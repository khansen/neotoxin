building_sect6_warps:
.db $30,$A7
.db $01,$87

building_sect6_room0:
.db $4C,$77,$77,$77,$77,$77,$77,$77
.db $4C,$3D,$3D,$3D,$3D,$3D,$3D,$3D
.db $4C,$7E,$5A,$7E,$5A,$59,$5A,$7E
.db $71,$00,$5A,$00,$5A,$59,$5A,$00
.db $4C,$00,$5A,$00,$1D,$1D,$1D,$00
.db $4C,$00,$5A,$00,$00,$4C,$5A,$00
.db $4C,$00,$5A,$7E,$7D,$71,$5A,$7E
.db $4C,$41,$41,$00,$00,$4C,$5A,$00
; building_sect6_room0_objects:
.db $FF
building_sect6_room1:
.db $77,$77,$4C,$77,$77,$77,$77,$4C
.db $3D,$3D,$4C,$3D,$3D,$3D,$3D,$4C
.db $5A,$7E,$4C,$16,$17,$16,$17,$4C
.db $5A,$00,$4C,$0B,$7F,$4F,$7F,$4C
.db $5A,$00,$4C,$0C,$7F,$7F,$07,$4C
.db $5A,$3C,$3C,$3C,$3C,$7F,$7F,$71
.db $5A,$7E,$5A,$7F,$7F,$07,$7F,$4C
.db $5A,$00,$5A,$0D,$0D,$0D,$0D,$4C
; building_sect6_room1_objects:
.db $02,$87,$00,$16
.db $FF
building_sect6_room2:
.db $4C,$00,$5A,$00,$00,$40,$40,$40
.db $71,$00,$5A,$00,$41,$53,$53,$53
.db $4C,$7E,$5A,$7E,$53,$7F,$4E,$7F
.db $4C,$00,$5A,$00,$0D,$0D,$0D,$0D
.db $4C,$3E,$3E,$3E,$3E,$3E,$3E,$3E
.db $4C,$7E,$5A,$7E,$5A,$59,$5A,$7E
.db $4C,$00,$5A,$00,$5A,$59,$5A,$00
.db $71,$00,$5A,$00,$5A,$59,$5A,$00
; building_sect6_room2_objects:
.db $FF
building_sect6_room3:
.db $40,$40,$40,$40,$40,$40,$40,$4C
.db $53,$53,$53,$00,$5A,$00,$00,$4C
.db $4F,$7F,$7F,$7E,$5A,$7E,$7D,$4C
.db $0D,$0D,$0D,$00,$5A,$00,$00,$4C
.db $3E,$3E,$57,$00,$5A,$00,$00,$71
.db $5A,$7E,$15,$7E,$5A,$7E,$7D,$4C
.db $5A,$00,$10,$00,$5A,$00,$19,$4C
.db $5A,$00,$71,$00,$5A,$00,$00,$4C
; building_sect6_room3_objects:
.db $FF
building_sect6_room4:
.db $4C,$7E,$5A,$7E,$1D,$1D,$1D,$7E
.db $4C,$00,$5A,$00,$5B,$15,$5B,$00
.db $4C,$00,$5A,$00,$5A,$10,$5A,$00
.db $4C,$41,$41,$00,$5A,$71,$5A,$00
.db $4C,$7E,$5A,$7E,$5A,$15,$5A,$7E
.db $71,$00,$5A,$00,$41,$10,$3E,$3E
.db $4C,$00,$5A,$00,$00,$10,$15,$15
.db $4C,$00,$5A,$00,$00,$3D,$3D,$3D
; building_sect6_room4_objects:
.db $FF
building_sect6_room5:
.db $5A,$7E,$15,$7E,$5A,$7E,$7D,$4C
.db $5A,$00,$10,$00,$5A,$00,$12,$4C
.db $5A,$56,$56,$56,$5A,$00,$12,$71
.db $5A,$00,$12,$00,$5A,$00,$12,$4C
.db $5A,$0D,$0D,$0D,$5A,$0D,$0D,$4C
.db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$4C
.db $15,$15,$15,$15,$15,$15,$15,$4C
.db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$4C
; building_sect6_room5_objects:
.db $FF
building_sect6_room6:
.db $4C,$3C,$3C,$0F,$00,$00,$00,$50
.db $4C,$00,$5B,$00,$0F,$00,$00,$51
.db $4C,$19,$19,$19,$19,$19,$19,$19
.db $4C,$6F,$1F,$6F,$1F,$6F,$1F,$6F
.db $71,$70,$20,$0B,$20,$70,$20,$70
.db $4C,$69,$20,$0C,$20,$69,$20,$69
.db $4C,$41,$41,$41,$41,$41,$41,$41
.db $4C,$00,$11,$11,$00,$00,$00,$11
; building_sect6_room6_objects:
.db $02,$A7,$00,$0D
.db $FF
building_sect6_room7:
.db $7E,$7D,$50,$7E,$7D,$7D,$5A,$4C
.db $00,$00,$51,$00,$00,$00,$5A,$4C
.db $19,$19,$19,$19,$19,$00,$5A,$71
.db $1F,$6F,$1F,$6F,$1F,$00,$5A,$4C
.db $20,$70,$20,$70,$20,$6F,$19,$4C
.db $20,$69,$20,$69,$20,$69,$6F,$4C
.db $41,$41,$41,$41,$41,$41,$41,$4C
.db $11,$00,$00,$00,$11,$11,$00,$4C
; building_sect6_room7_objects:
.db $FF
building_sect6_map:
.dw building_sect6_room0,building_sect6_room1,building_sect6_room2,building_sect6_room3
.dw building_sect6_room4,building_sect6_room5,building_sect6_room6,building_sect6_room7
