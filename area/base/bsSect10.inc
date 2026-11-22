base_sect10_room0:
.db $52,$3F,$3F,$3F,$3F,$3F,$3F,$3F
.db $52,$3E,$25,$25,$25,$3E,$25,$25
.db $52,$1F,$1F,$1F,$1F,$1F,$1F,$1F
.db $52,$3E,$00,$37,$00,$3E,$00,$37
.db $52,$3E,$00,$37,$00,$3E,$00,$37
.db $52,$1F,$1F,$1F,$1F,$1F,$1F,$1F
.db $52,$5F,$5F,$5F,$5F,$5F,$5F,$5F
.db $52,$41,$41,$41,$41,$41,$41,$41
base_sect10_room0_objects:
.db $FF
base_sect10_room1:
.db $3F,$3F,$3F,$3F,$3F,$3F,$3F,$74
.db $25,$3E,$25,$25,$25,$3E,$25,$74
.db $1F,$1F,$1F,$1F,$1F,$1F,$1F,$74
.db $00,$3E,$00,$37,$00,$3E,$00,$74
.db $00,$3E,$00,$37,$00,$3E,$00,$2C
.db $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
.db $5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
.db $41,$41,$41,$41,$41,$41,$41,$41
base_sect10_room1_objects:
.db $03,$CF,$40,$0C,$FF
base_sect10_map:
.dw base_sect10_room0,base_sect10_room1
base_sect10_warps:
.db $01, $CE ; 00
