neox005_chn0_pat0:
.db $08,$FF,$EB,$F0,$E8,$08,$2E,$35,$37,$31,$2E,$35,$37,$31
neox005_chn0_pat1:
.db $40,$01,$EB,$F0,$E8,$09,$22,$10,$20,$01,$23,$11,$27,$2A
.db $01,$EB,$F0,$E8,$09,$29,$10,$27,$01,$2C,$11,$2F,$2C
neox005_chn0_pat2:
.db $20,$05,$EB,$F0,$E8,$09,$2E,$EB,$40,$2E,$05,$EB,$F0,$2E,$EB,$40
.db $2E,$05,$EB,$F0,$33,$EB,$40,$33,$05,$EB,$F0,$31,$EB,$40,$31

neox005_chn1_pat0:
.db $20,$FF,$EB,$70,$E8,$0E,$35,$2F,$2E,$35,$37,$31,$2E,$35,$FF,$37
.db $31,$2E,$35,$37,$31,$2E,$35,$FF,$37,$31,$2C,$33,$35,$2F,$2C,$33
.db $FF,$35,$2F,$2C,$33,$35,$2F,$2C,$33
neox005_chn1_pat1:
.db $20,$FF,$EB,$70,$E8,$0E,$35,$2F,$2E,$35,$37,$31,$2E,$35,$FF,$37
.db $31,$2E,$35,$37,$31,$2E,$35,$FF,$37,$31,$2C,$33,$35,$2F,$2C,$33
.db $FF,$35,$2F,$2C,$33,$35,$2F,$2C,$33

neox005_chn2_pat0:
.db $20,$00,$00,$00,$00
neox005_chn2_pat1:
.db $20,$01,$E8,$00,$16,$01,$14,$09,$E8,$06,$0F,$0F,$00
neox005_chn2_pat2:
.db $20,$FF,$E8,$00,$2E,$35,$37,$31,$2E,$35,$37,$31,$FF,$2E,$35,$37
.db $31,$2E,$35,$37,$31,$FF,$2C,$33,$35,$2F,$2C,$33,$35,$2F,$FF,$2C
.db $33,$35,$2F,$2C,$33,$35,$E8,$06,$2F

neox005_patterns:
.dw neox005_chn0_pat0
.dw neox005_chn0_pat1
.dw neox005_chn0_pat2
.dw neox005_chn1_pat0
.dw neox005_chn1_pat1
.dw neox005_chn2_pat0
.dw neox005_chn2_pat1
.dw neox005_chn2_pat2

neox005_order0:
.db $FB,4,$82,$00,$FD,-2,$82,$00,$FC,$01,$02,$02,$FE,0
neox005_order1:
.db $03,$03,$84,$04,$FE,0
neox005_order2:
.db $05,$05,$06,$06,$84,$07,$FE,0

neox005:
.dw neox005_order0 : .db 14
.dw neox005_order1 : .db 14
.dw neox005_order2 : .db 14
.db 0,0,0
.db 0,0,0
.dw neox005_patterns
