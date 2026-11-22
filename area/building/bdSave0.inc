; Ruins saveroom #1
building_save0_room0:
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$1D,$56,$56,$56,$56,$1D,$00
.db $00,$1D,$59,$59,$59,$59,$1D,$00
.db $00,$1D,$5A,$5A,$5A,$5A,$1D,$00
.db $00,$1D,$05,$5B,$27,$28,$1D,$00
.db $00,$1D,$0C,$52,$25,$26,$1D,$00
.db $00,$58,$3E,$3E,$3E,$3E,$57,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
; building_save0_room0_objects:
.db $03,$AA
.db <SaveScript,>SaveScript
.db $02,$A5,$00,$01
.db $FF
building_save0_map:
.dw building_save0_room0
building_save0_warps:
.db $00, $A5
