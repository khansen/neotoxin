neox022_chn0_pat0:
.db $08,$FF,$EB,$F0,$E8,$04,$2B,$32,$30,$2B,$24,$29,$2B,$30
neox022_chn1_pat0:
.db $08,$FF,$EB,$80,$E8,$04,$2B,$30,$2B,$32,$30,$2B,$24,$29
neox022_chn2_pat0:
.db $40,$01,$E8,$00,$24,$00,$00,$00,$01,$27,$00,$00,$00
neox022_chn3_pat0:
.db $08,$00
neox022_chn2_pat1:
.db $40,$01,$E8,$00,$20,$00,$00,$00,$01,$1D,$00,$00,$10,$16
neox022_chn2_pat2:
.db $40,$6D,$E8,$01,$18,$18,$18,$18,$18,$6D,$18,$18,$18,$18,$18
.db $6D,$18,$18,$18,$18,$18,$6D,$18,$18,$18,$18,$18,$6D,$1B,$1B,$1B
.db $1B,$1B,$6D,$1B,$1B,$1B,$1B,$1B,$6D,$1B,$1B,$1B,$1B,$1B,$6D,$1B
.db $1B,$1B,$1B,$1B
neox022_chn3_pat1:
.db $08,$49,$EB,$F0,$02,$02,$02
neox022_chn2_pat3:
.db $40,$6D,$E8,$01,$14,$14,$14,$14,$14,$6D,$14,$14,$14,$14,$14
.db $6D,$14,$14,$14,$14,$14,$6D,$14,$14,$14,$14,$14,$6D,$11,$11,$11
.db $11,$11,$6D,$11,$11,$11,$11,$11,$6D,$11,$11,$11,$11,$11,$6D,$11
.db $11,$11,$11,$16
neox022_chn1_pat1:
.db $40,$01,$EB,$F0,$E8,$09,$24,$00,$00,$00,$01,$22,$00,$01,$1F
.db $00
neox022_chn1_pat2:
.db $40,$01,$EB,$F0,$E8,$09,$1F,$00,$01,$1D,$00,$41,$24,$EB,$C0
.db $24,$10,$EB,$80,$24,$04,$EB,$40,$24,$01,$EB,$20,$24
neox022_patterns:
.dw neox022_chn0_pat0
.dw neox022_chn1_pat0
.dw neox022_chn1_pat1
.dw neox022_chn1_pat2
.dw neox022_chn2_pat0
.dw neox022_chn2_pat1
.dw neox022_chn2_pat2
.dw neox022_chn2_pat3
.dw neox022_chn3_pat0
.dw neox022_chn3_pat1
neox022_order0:
.db $00,$FE,0
neox022_order1:
.db $A0,$01,$02,$03,$FE,0
neox022_order2:
.db $04,$05,$06,$07,$FD,12,$06,$FD,12,$07,$FE,0
neox022_order3:
.db $90,$08,$A0,$09,$FE,0
neox022:
.dw neox022_order0 : .db 7
.dw neox022_order1 : .db 7
.dw neox022_order2 : .db 7
.dw neox022_order3 : .db 7
.db 0,0,0
.dw neox022_patterns
