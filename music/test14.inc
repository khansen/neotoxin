test14_chn0_pat0:
.db $40,$55,$EB,$F0,$E8,$00,$25,$29,$23,$2A,$55,$27,$29,$23,$2F,$55
.db $25,$29,$23,$2A,$55,$27,$29,$23,$2F,$55,$25,$28,$23,$2A,$55,$27
.db $28,$23,$2F,$55,$25,$28,$23,$2A,$55,$27,$28,$23,$31
test14_chn1_pat0:
.db $40,$AA,$EB,$80,$E8,$00,$31,$25,$29,$23,$AA,$2A,$27,$29,$23,$AA
.db $2F,$25,$29,$23,$AA,$2A,$27,$29,$23,$AA,$2F,$25,$28,$23,$AA,$2A
.db $27,$28,$23,$AA,$2F,$25,$28,$23,$AA,$2A,$27,$28,$23
test14_chn2_pat0:
.db $20,$AD,$E8,$01,$19,$19,$19,$19,$19,$AD,$19,$19,$19,$19,$19,$AD
.db $19,$19,$19,$19,$19,$AD,$19,$19,$19,$19,$19
test14_chn3_pat0:
.db $10,$55,$EB,$F0,$00,$01,$00,$01,$55,$00,$01,$00,$01
test14_chn4_pat0:
.db $10,$11,$1B,$1B,$11,$1B,$1B
test14_patterns:
.dw test14_chn0_pat0
.dw test14_chn1_pat0
.dw test14_chn2_pat0
.dw test14_chn3_pat0
.dw test14_chn4_pat0
test14_order0:
.db $00,$FE,0
test14_order1:
.db $01,$FE,0
test14_order2:
.db $02,$FD,-4,$02,$FE,0
test14_order3:
.db $03,$FE,0
test14_order4:
.db $04,$FE,0
test14:
.dw test14_order0 : .db 7
.dw test14_order1 : .db 7
.dw test14_order2 : .db 7
.dw test14_order3 : .db 7
.dw test14_order4 : .db 7
.dw test14_patterns
