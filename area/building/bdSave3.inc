; Plant saveroom #2
building_save3_room0:
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$1D,$56,$56,$56,$56,$1D,$00
.db $00,$1D,$59,$59,$59,$59,$1D,$00
.db $00,$1D,$5A,$5A,$5A,$5A,$1D,$00
.db $00,$1D,$05,$5B,$27,$28,$1D,$00
.db $00,$1D,$0C,$52,$25,$26,$1D,$00
.db $00,$58,$3E,$3E,$3E,$3E,$57,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
building_save3_room0_objects:
.db $03,$AA,<SaveScript,>SaveScript,$02,$A5,$20,$02
.db $FF
building_save3_map:
.dw building_save3_room0
building_save3_warps:
.db $00, $A5
