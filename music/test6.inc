test6_chn0_pat0:
.db $40,$49,$EB,$F0,$E8,$0A,$23,$25,$25,$52,$26,$23,$25,$15,$25,$26
.db $20,$00,$C0,$E8,$0D,$23,$1E,$FF,$17,$EB,$D0,$23,$1E,$17,$EB,$A0
.db $23,$1E,$17,$EB,$60,$23,$1F,$1E,$17,$EB,$40,$23,$1E,$17,$00
test6_chn0_pat1:
.db $40,$01,$EB,$F0,$E8,$06,$26,$00,$00,$00,$01,$28,$00,$00,$00
test6_chn0_pat2:
.db $40,$01,$EB,$F0,$E8,$06,$29,$00,$00,$00,$01,$2A,$00,$00,$00
test6_chn0_pat3:
.db $40,$49,$EB,$F0,$E8,$0A,$E5,$50,$23,$E5,$40,$25,$25,$52,$26,$E5
.db $50,$23,$E5,$40,$25,$15,$25,$26,$E5,$60,$20,$00,$C0,$E8,$0D,$E0
.db $23,$1E,$FF,$17,$EB,$D0,$23,$1E,$17,$EB,$A0,$23,$1E,$17,$EB,$60
.db $23,$1F,$1E,$17,$EB,$40,$23,$1E,$17,$00
test6_chn0_pat4:
.db $0E,$49,$EB,$F0,$E8,$0A,$23,$25,$23,$15,$25,$26,$27
test6_chn0_pat5:
.db $40,$01,$EB,$F0,$E8,$02,$2A,$41,$26,$2A,$51,$2B,$32,$2F,$04,$2A
.db $01,$2B,$41,$2E,$2A,$51,$2B,$2A,$2E,$04,$2B
test6_chn0_pat6:
.db $40,$01,$EB,$F0,$E8,$02,$2F,$41,$26,$2B,$51,$32,$2A,$2B,$04,$31
.db $01,$2E,$41,$31,$2A,$51,$2E,$2F,$31,$04,$34

test6_chn1_pat0:
.db $40,$49,$EB,$F0,$E8,$0E,$28,$29,$29,$52,$2A,$28,$29,$15,$29,$2A
.db $26,$10,$E8,$06,$23,$00,$00,$00,$00
test6_chn1_pat1:
.db $08,$FF,$EB,$F0,$E8,$0D,$2F,$EB,$80,$3E,$EB,$F0,$36,$EB,$80,$2F
.db $EB,$F0,$3B,$EB,$80,$36,$EB,$F0,$3E,$EB,$80,$3B
test6_chn1_pat2:
.db $08,$55,$EB,$40,$E8,$0E,$23,$EB,$F0,$23,$EB,$40,$23,$EB,$F0,$23
test6_chn1_pat3:
.db $0E,$49,$EB,$F0,$E8,$0E,$28,$29,$28,$15,$29,$2A,$2B
test6_chn1_pat4:
.db $40,$08,$EB,$80,$E8,$02,$2A,$08,$26,$8A,$2A,$2B,$32,$22,$2F,$2A
.db $08,$2B,$08,$2E,$8A,$2A,$2B,$2A,$22,$2E,$2B
test6_chn1_pat5:
.db $40,$08,$EB,$80,$E8,$02,$2F,$08,$26,$8A,$2B,$32,$2A,$22,$2B,$31
.db $08,$2E,$08,$31,$8A,$2A,$2E,$2F,$22,$31,$34

test6_chn2_pat0:
.db $10,$49,$E8,$06,$17,$17,$E8,$01,$17,$25,$17,$E8,$06,$17,$17
test6_chn2_pat1:
.db $0E,$00,$00

test6_chn3_pat0:
.db $10,$5B,$EB,$F0,$00,$00,$00,$02,$00,$5D,$00,$00,$00,$02,$00

test6_chn4_pat0:
.db $40,$41,$1B,$1B,$04,$1B,$41,$1B,$1B,$24,$1B,$1B,$41,$1B,$1B,$04
.db $1B,$41,$1B,$1B,$44,$1B,$1B

test6_patterns:
.dw test6_chn0_pat0
.dw test6_chn0_pat1
.dw test6_chn0_pat2
.dw test6_chn0_pat3
.dw test6_chn0_pat4
.dw test6_chn0_pat5
.dw test6_chn0_pat6
.dw test6_chn1_pat0
.dw test6_chn1_pat1
.dw test6_chn1_pat2
.dw test6_chn1_pat3
.dw test6_chn1_pat4
.dw test6_chn1_pat5
.dw test6_chn2_pat0
.dw test6_chn2_pat1
.dw test6_chn3_pat0
.dw test6_chn4_pat0

test6_order0:
.db $04,$00,$00,$05,$06,$05,$06,$03,$03,$01,$02,$01,$02,$FE,1
test6_order1:
.db $0A,$07,$07,$0B,$0C,$0B,$0C,$90,$09,$A0,$08,$FE,1
test6_order2:
.db $0E,$88,$0D,$FB,2,$82,$0D,$FD,-1,$82,$0D,$FD,-4,$82,$0D,$FD,-1,$82,$0D,$FC,$FD,12,$88,$0D,$90,$0D,$FE,1
test6_order3:
.db $0E,$C0,$0F,$FE,1
test6_order4:
.db $0E,$88,$10,$FE,1

test6:
.dw test6_order0 : .db 7
.dw test6_order1 : .db 7
.dw test6_order2 : .db 7
.dw test6_order3 : .db 7
.dw test6_order4 : .db 7
.dw test6_patterns
