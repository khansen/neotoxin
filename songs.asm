.include "songs.h"
.codeseg

.public RNME_SongPtrTable

;************************** SONG DATA BEGINS HERE! ***************************

RNME_SongPtrTable:
.dw test3
.dw test6
.dw test9
.dw test10
.dw test11
.dw test12
.dw test14
.dw test15
.dw neox003
.dw neox005
.dw neox007
.dw neox009
.dw neox014
.dw neox017
.dw neox022
.dw neox093

.incsrc "music/neox005.inc"
.incsrc "music/test6.inc"
.incsrc "music/neox009.inc"
.incsrc "music/neox017.inc"
.incsrc "music/test12.inc"
.incsrc "music/test9.inc"
.incsrc "music/test10.inc"
.incsrc "music/test15.inc"
.incsrc "music/test11.inc"
.incsrc "music/test14.inc"
.incsrc "music/neox093.inc"
.incsrc "music/neox003.inc"
.incsrc "music/neox014.inc"
.incsrc "music/neox022.inc"
.incsrc "music/neox007.inc"

; --------------------------------[ neo001 ]----------------------------------

test3:
.dw test3_order0 : .db 7
.dw test3_order1 : .db 7
.dw test3_order2 : .db 7
.db 0,0,0
.db 0,0,0
.dw test3_patptrtable

test3_order0:
.db 0,1,$FE,0
test3_order1:
.db 2,3,$FE,0
test3_order2:
.db 4,5,$FE,0

test3_patptrtable:
.dw test3_chn0_pat0
.dw test3_chn0_pat1
.dw test3_chn1_pat0
.dw test3_chn1_pat1
.dw test3_chn2_pat0
.dw test3_chn2_pat1

test3_chn0_pat0:
.db $30,$AD,$E8,$0C,$2C,$23,$25,$2A,$23,$D5,$25,$2A,$2C,$23,$25,$5A
.db $2A,$23,$25,$2A,$AD,$2C,$23,$25,$2A,$23,$D5,$25,$2A,$2C,$23,$25
.db $DA,$2A,$23,$25,$2C,$2E
test3_chn1_pat0:
.db $30,$B4,$EB,$80,$E8,$0C,$2C,$23,$25,$2A,$56,$23,$25,$2A,$2C,$6B,$23,$25
.db $2A,$23,$25,$B5,$2A,$2C,$23,$25,$2A,$56,$23,$25,$2A,$2C,$6B,$23
.db $25,$2A,$23,$25
test3_chn2_pat0:
.db $30,$01,$E8,$00,$20,$00,$00,$01,$1C,$00,$00
test3_chn0_pat1:
.db $30,$AD,$E8,$0C,$2F,$28,$2A,$2F,$28,$DD,$2A,$2C,$2E,$2F,$28,$2A
.db $DA,$2F,$28,$2A,$2C,$2E,$AD,$2F,$28,$2A,$2F,$28,$DD,$2A,$2C,$2E
.db $2F,$28,$2A,$DA,$2F,$28,$2A,$2C,$2E
test3_chn1_pat1:
.db $30,$B4,$E8,$0C,$2F,$28,$2A,$2F,$76,$28,$2A,$2C,$2E,$2F,$6B,$28
.db $2A,$2F,$28,$2A,$B7,$2C,$2E,$2F,$28,$2A,$2F,$76,$28,$2A,$2C,$2E
.db $2F,$6B,$28,$2A,$2F,$28,$2A
test3_chn2_pat1:
.db $30,$01,$E8,$00,$19,$00,$00,$01,$1E,$00,$00

.end
