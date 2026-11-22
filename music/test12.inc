test12_chn0_pat0:
.db $10,$FF,$EB,$F0,$E8,$0A,$27,$2D,$EB,$F0,$2D,$EB,$D0,$2D,$EB,$B0
.db $2D,$EB,$90,$2D,$EB,$70,$2D,$EB,$60,$2D,$0F,$EB,$40,$2D,$EB,$30
.db $2D,$EB,$20,$2D,$EB,$10,$2D
test12_chn1_pat0:
.db $08,$55,$EB,$F0,$E8,$0E,$E5,$80,$27,$EB,$80,$27,$EB,$F0,$27,$EB
.db $80,$27
test12_chn2_pat0:
.db $20,$01,$E8,$00,$1B,$00,$01,$19,$00
test12_patterns:
.dw test12_chn0_pat0
.dw test12_chn1_pat0
.dw test12_chn2_pat0
test12_order0:
.db $84,$00,$FD,1,$84,$00,$FE,0
test12_order1:
.db $88,$01,$FD,1,$88,$01,$FE,0
test12_order2:
.db $02,$02,$FD,1,$82,$02,$FE,0
test12:
.dw test12_order0 : .db 11
.dw test12_order1 : .db 11
.dw test12_order2 : .db 11
.db 0,0,0
.db 0,0,0
.dw test12_patterns
