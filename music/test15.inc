test15_chn0_pat0:
.db $40,$1D,$EB,$F0,$E8,$01,$26,$25,$26,$23,$00,$00,$C0,$21,$23
.db $01,$1E,$00,$00,$44,$2A,$28
test15_chn0_pat1:
.db $40,$1D,$EB,$F0,$E8,$01,$26,$25,$26,$23,$00,$00,$C0,$21,$23
.db $1D,$28,$26,$28,$23,$00,$00,$00
test15_chn0_pat2:
.db $40,$10,$EB,$F0,$E8,$0E,$23,$04,$1E,$41,$21,$1C,$10,$1A,$10
.db $23,$04,$1E,$41,$21,$1E,$10,$26
test15_chn1_pat0:
.db $40,$E8,$EB,$80,$E8,$01,$26,$25,$26,$23,$00,$00,$00,$0E,$21
.db $23,$1E,$00,$00,$20,$2A
test15_chn1_pat1:
.db $40,$EA,$EB,$80,$E8,$01,$28,$26,$25,$26,$23,$00,$00,$00,$EE
.db $21,$23,$28,$26,$28,$23,$00,$00,$00
test15_chn1_pat2:
.db $40,$80,$EB,$80,$E8,$0E,$23,$20,$1E,$08,$21,$82,$1C,$1A,$80
.db $23,$20,$1E,$08,$21,$82,$1E,$26
test15_chn2_pat0:
.db $40,$01,$E8,$00,$17,$00,$00,$00,$00,$00,$00,$00
test15_chn2_pat1:
.db $40,$01,$E8,$00,$13,$00,$00,$00,$01,$1C,$00,$00,$00
test15_chn2_pat2:
.db $40,$01,$E8,$00,$13,$00,$00,$00,$01,$1C,$00,$00,$00
test15_chn2_pat3:
.db $40,$01,$E8,$00,$17,$00,$00,$00,$01,$15,$00,$00,$00
test15_chn3_pat0:
.db $10,$51,$EB,$F0,$00,$02,$EB,$80,$02,$51,$EB,$F0,$00,$00,$01
test15_chn4_pat0:
.db $20,$05,$1B,$1B,$40,$1B,$01,$1B,$40,$1B
test15_patterns:
.dw test15_chn0_pat0
.dw test15_chn0_pat1
.dw test15_chn0_pat2
.dw test15_chn1_pat0
.dw test15_chn1_pat1
.dw test15_chn1_pat2
.dw test15_chn2_pat0
.dw test15_chn2_pat1
.dw test15_chn2_pat2
.dw test15_chn2_pat3
.dw test15_chn3_pat0
.dw test15_chn4_pat0
test15_order0:
.db $00,$01,$00,$01,$84,$02,$FE,0
test15_order1:
.db $03,$04,$03,$04,$84,$05,$FE,0
test15_order2:
.db $06,$07,$06,$07,$08,$09,$08,$09,$FE,0
test15_order3:
.db $0A,$FE,0
test15_order4:
.db $0B,$FE,0
test15:
.dw test15_order0 : .db 7
.dw test15_order1 : .db 7
.dw test15_order2 : .db 7
.dw test15_order3 : .db 7
.dw test15_order4 : .db 7
.dw test15_patterns
