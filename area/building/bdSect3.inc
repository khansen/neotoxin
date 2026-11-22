building_sect3_warps:
.db $00,$A5
.db $11,$CB

building_sect3_room0:
.db $4C,$77,$77,$77,$77,$77,$10,$77
.db $4C,$76,$76,$76,$76,$76,$10,$77
.db $4C,$7E,$7D,$7D,$7D,$7D,$10,$77
.db $71,$4A,$44,$7F,$44,$4A,$76,$76
.db $4C,$7F,$0B,$7F,$07,$7F,$4A,$00
.db $4C,$0D,$0C,$0D,$0D,$0D,$4A,$6D
.db $4C,$42,$42,$42,$42,$42,$0F,$00
.db $71,$00,$6F,$6F,$6E,$6C,$00,$0F
; building_sect3_room0_objects:
.db $02,$A5,$00,$02
.db $FF
building_sect3_room1:
.db $77,$10,$77,$77,$77,$77,$77,$4C
.db $77,$10,$76,$76,$76,$76,$76,$4C
.db $77,$10,$7E,$7D,$7D,$7D,$7D,$4C
.db $76,$76,$00,$00,$00,$00,$6E,$71
.db $6F,$6F,$6E,$70,$6D,$6C,$6A,$4C
.db $4D,$4D,$4D,$4E,$6C,$42,$42,$4C
.db $6B,$6A,$4D,$4D,$6C,$6D,$4D,$4C
.db $00,$00,$6A,$6B,$00,$00,$6A,$71
; building_sect3_room1_objects:
.db $FF
building_sect3_room2:
.db $4C,$70,$6A,$4E,$4D,$6C,$42,$42
.db $4C,$4D,$6C,$6A,$6B,$00,$00,$6E
.db $4C,$6B,$00,$42,$42,$0F,$6E,$4D
.db $71,$6F,$00,$6F,$00,$42,$42,$42
.db $4C,$4D,$70,$6B,$00,$00,$00,$6E
.db $4C,$42,$42,$0F,$00,$00,$6E,$67
.db $4C,$70,$6F,$00,$0F,$6E,$67,$67
.db $4C,$41,$41,$41,$41,$41,$41,$41
; building_sect3_room2_objects:
.db $FF
building_sect3_room3:
.db $42,$42,$00,$6E,$6C,$0E,$42,$4C
.db $70,$6F,$00,$6B,$0E,$6F,$6E,$4C
.db $4E,$4D,$70,$0E,$6E,$4D,$4D,$4C
.db $42,$42,$42,$42,$42,$42,$42,$71
.db $79,$6E,$79,$6E,$79,$78,$67,$4C
.db $79,$67,$79,$67,$79,$05,$67,$4C
.db $79,$67,$79,$67,$79,$0C,$67,$4C
.db $41,$41,$41,$41,$41,$41,$41,$4C
; building_sect3_room3_objects:
.db $02,$CB,$40,$01
.db $FF
building_sect3_map:
.dw building_sect3_room0,building_sect3_room1,building_sect3_room2,building_sect3_room3
