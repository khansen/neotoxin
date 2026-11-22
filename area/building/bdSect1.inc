building_sect1_warps:
.db $00,$A7

building_sect1_room0:
.db $4C,$77,$77,$77,$77,$77,$77,$4C
.db $4C,$08,$08,$3D,$3D,$08,$08,$4C
.db $4C,$11,$11,$11,$11,$11,$11,$3D
.db $71,$17,$16,$16,$16,$17,$16,$17
.db $4C,$6D,$4F,$0B,$4E,$4D,$74,$4F
.db $4C,$6D,$4D,$0C,$4D,$52,$4D,$4D
.db $4C,$41,$41,$41,$41,$41,$41,$41
.db $4C,$0D,$0D,$0D,$0D,$0D,$0D,$0D
; building_sect1_room0_objects:
.db $02,$A7,$00,$15,$04,$BC
.db $FF
building_sect1_room1:
.db $4C,$77,$77,$77,$77,$77,$77,$4C
.db $4C,$08,$08,$3D,$3D,$08,$08,$4C
.db $3D,$53,$53,$53,$53,$53,$11,$08
.db $53,$7F,$7F,$7F,$7F,$7F,$12,$53
.db $70,$6E,$4E,$74,$4D,$4F,$4D,$74
.db $4D,$52,$4D,$69,$6B,$6B,$6A,$4D
.db $0F,$6A,$69,$66,$68,$68,$65,$6A
.db $00,$41,$41,$41,$41,$41,$41,$41
; building_sect1_room1_objects:
.db $04,$3B
.db $FF
building_sect1_room2:
.db $4C,$77,$77,$77,$77,$77,$77,$4C
.db $4C,$08,$08,$3D,$3D,$08,$08,$3D
.db $08,$53,$53,$53,$53,$11,$53,$53
.db $53,$7F,$07,$7F,$53,$12,$7F,$07
.db $4E,$70,$6E,$4F,$74,$4D,$4E,$52
.db $4D,$4D,$4D,$4D,$52,$4D,$4D,$4D
.db $52,$4D,$69,$6A,$4D,$52,$69,$0E
.db $41,$41,$41,$41,$41,$41,$41,$00
; building_sect1_room2_objects:
.db $04,$D4
.db $FF
building_sect1_room3:
.db $4C,$77,$77,$77,$77,$77,$77,$4C
.db $3D,$08,$08,$3D,$3D,$08,$08,$4C
.db $17,$16,$16,$16,$16,$17,$16,$4C
.db $16,$17,$00,$7E,$17,$16,$16,$71
.db $74,$4F,$70,$6E,$4E,$74,$70,$4C
.db $4D,$4D,$4D,$4D,$52,$4D,$52,$4C
.db $41,$41,$41,$41,$41,$41,$41,$4C
.db $0D,$0D,$0D,$0D,$0D,$0D,$0D,$4C
; building_sect1_room3_objects:
.db $FF
building_sect1_map:
.dw building_sect1_room0,building_sect1_room1,building_sect1_room2,building_sect1_room3
