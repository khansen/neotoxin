building_sect10_warps:
.db $10,$AF

building_sect10_room0:
.db $15,$15,$15,$15,$15,$15,$15,$15
.db $10,$3D,$3D,$3D,$3D,$3D,$3D,$3D
.db $10,$00,$5A,$00,$4A,$5A,$00,$00
.db $71,$00,$4E,$00,$4A,$4F,$00,$5B
.db $15,$00,$59,$00,$4A,$59,$00,$0E
.db $10,$00,$59,$3C,$3C,$3C,$3C,$3C
.db $10,$00,$59,$00,$4A,$5A,$00,$4A
.db $71,$4A,$4F,$00,$4A,$4F,$00,$4A
building_sect10_room0_objects:
.db $FF
building_sect10_room1:
.db $15,$15,$15,$15,$15,$15,$15,$15
.db $3D,$3D,$3D,$3D,$56,$56,$56,$10
.db $78,$74,$79,$00,$00,$00,$00,$10
.db $73,$4D,$72,$5B,$00,$5B,$00,$71
.db $1D,$1D,$1D,$0F,$6F,$70,$6F,$15
.db $3C,$3C,$3C,$3C,$19,$19,$19,$10
.db $5A,$00,$00,$00,$00,$5A,$00,$10
.db $4E,$00,$00,$4A,$4A,$4F,$4A,$71
building_sect10_room1_objects:
.db $FF
building_sect10_room2:
.db $15,$4A,$59,$00,$44,$59,$00,$44
.db $7C,$30,$31,$30,$31,$30,$31,$30
.db $10,$00,$6E,$74,$52,$74,$70,$11
.db $71,$78,$4F,$52,$2F,$4E,$4D,$52
.db $15,$73,$69,$6B,$6A,$4D,$52,$0B
.db $10,$73,$4D,$70,$6E,$70,$6A,$0C
.db $10,$42,$42,$42,$42,$42,$42,$42
.db $10,$7F,$7F,$7F,$7F,$7F,$7F,$7F
building_sect10_room2_objects:
.db $02,$AF,$00,$04
.db $FF
building_sect10_room3:
.db $59,$00,$4A,$4A,$4A,$59,$4A,$15
.db $14,$31,$6F,$6F,$30,$14,$31,$10
.db $6E,$74,$4D,$52,$74,$70,$00,$7C
.db $4D,$4F,$2F,$4D,$4E,$4D,$79,$71
.db $6A,$52,$4D,$69,$6A,$52,$72,$15
.db $6F,$6A,$6B,$6F,$6F,$6A,$72,$10
.db $42,$42,$42,$42,$42,$42,$42,$10
.db $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7C
building_sect10_room3_objects:
.db $FF
building_sect10_map:
.dw building_sect10_room0,building_sect10_room1,building_sect10_room2,building_sect10_room3
