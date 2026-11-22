.codeseg

.public RNME_FreqTabLo
.public RNME_FreqTabHi
.public RNME_DMCDataTable
.public RNME_VolTable
.public RNME_ChnOffset
.public RNME_TriangleData
.public RNME_SquareData
.public RNME_NoiseData
.public RNME_VibratoTable

;----------------------------------[ Data ]-----------------------------------

; volume table used for scaling channel volume according to master volume

RNME_VolTable:
.db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30      ; MasterVol = 0
.db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$31      ; 1
.db $30,$30,$30,$30,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$32      ; 2
.db $30,$30,$30,$30,$30,$31,$31,$31,$31,$31,$32,$32,$32,$32,$32,$33      ; 3
.db $30,$30,$30,$30,$31,$31,$31,$31,$32,$32,$32,$32,$33,$33,$33,$34      ; ..
.db $30,$30,$30,$31,$31,$31,$32,$32,$32,$33,$33,$33,$34,$34,$34,$35
.db $30,$30,$30,$31,$31,$32,$32,$32,$33,$33,$34,$34,$34,$35,$35,$36
.db $30,$30,$30,$31,$31,$32,$32,$33,$33,$34,$34,$35,$35,$36,$36,$37
.db $30,$30,$31,$31,$32,$32,$33,$33,$34,$34,$35,$35,$36,$36,$37,$38
.db $30,$30,$31,$31,$32,$33,$33,$34,$34,$35,$36,$36,$37,$37,$38,$39
.db $30,$30,$31,$32,$32,$33,$34,$34,$35,$36,$36,$37,$38,$38,$39,$3A
.db $30,$30,$31,$32,$32,$33,$34,$35,$35,$36,$37,$38,$38,$39,$3A,$3B
.db $30,$30,$31,$32,$33,$34,$34,$35,$36,$37,$38,$38,$39,$3A,$3B,$3C
.db $30,$30,$31,$32,$33,$34,$35,$36,$36,$37,$38,$39,$3A,$3B,$3C,$3D
.db $30,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E
.db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F

RNME_FreqTabLo:
.db                                     $F1,$7F,$13 ; A-1 .. B-1
.db $AE,$4E,$F3,$9E,$4D,$01,$B9,$75,$35,$F8,$BF,$89 ; C-2 .. B-2
.db $57,$27,$F9,$CF,$A6,$80,$5C,$3A,$1A,$FC,$DF,$C4 ; C-3 .. B-3
.db $AB,$93,$7C,$67,$53,$40,$2E,$1D,$0D,$FE,$EF,$E2 ; C-4 .. B-4
.db $D5,$C9,$BE,$B3,$A9,$A0,$97,$8E,$86,$7F,$79,$71 ; C-5 .. B-5
.db $6A,$64,$5F,$59,$54,$50,$4B,$47,$43,$3F,$3B,$38 ; C-6 .. B-6
.db $35,$32,$2F,$2C,$2A,$28,$25,$23,$21,$1F,$1D,$1C ; C-7 .. B-7

RNME_FreqTabHi:
.db                                     $07,$07,$07
.db $06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03
.db $03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01
.db $01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; ProTracker sine table used for vibrato

RNME_VibratoTable:
.db $00,$18,$31,$4A,$61,$78,$8D,$A1
.db $B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
.db $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5
.db $B4,$A1,$8D,$78,$61,$4A,$31,$18

RNME_ChnOffset:
.db $00,$04,$08,$0C

;-----------------------[ Square channel instruments ]------------------------
;
; format:   byte 0-1: ptr to volume envelope
;           byte 2: waveinfo (duty cycle)
;           byte 3: resvib
;           byte 4: effect
;           byte 5: effect param
;           byte 6-7: unused

RNME_SquareData:
.dw square_env00 : .db $23,$00,$04,$61 : .db $00,$00
.dw square_env01 : .db $80,$20,$04,$41 : .db $00,$00
.dw square_env02 : .db $80,$10,$04,$61 : .db $00,$00
.dw square_env03 : .db $80,$00,$00,$00 : .db $00,$00
.dw square_env04 : .db $80,$00,$00,$00 : .db $00,$00
.dw square_env05 : .db $40,$00,$00,$00 : .db $00,$00
.dw square_env06 : .db $40,$00,$04,$81 : .db $00,$00
.dw square_env07 : .db $00,$00,$00,$00 : .db $00,$00
.dw square_env08 : .db $40,$00,$00,$00 : .db $00,$00
.dw square_env09 : .db $00,$00,$04,$62 : .db $00,$00
.dw square_env10 : .db $84,$00,$00,$00 : .db $00,$00
.dw square_env11 : .db $14,$00,$00,$00 : .db $00,$00
.dw square_env12 : .db $80,$00,$00,$00 : .db $00,$00
.dw square_env13 : .db $80,$00,$00,$00 : .db $00,$00
.dw square_env14 : .db $93,$00,$00,$00 : .db $00,$00
.dw square_env15 : .db $80,$00,$00,$00 : .db $00,$00

square_env00:
.db $0A
.db $01,$00,$00,$03
.db $FF,$FF
square_env01:
.db $08
.db $01,$00,$00,$06
.db $FF,$FF
square_env02:
.db $0A
.db $01,$00,$04,$09
.db $05,$00,$00,$04
.db $00,$10,$00,$00
.db $FF,$FF
square_env03:
.db $00
.db $00,$08,$00,$04
.db $00,$08,$00,$00
.db $FF,$FF
square_env04:
.db $0A
.db $01,$00,$00,$01
.db $FF,$FF
square_env05:
.db $0C
.db $00,$C0,$00,$02
.db $01,$00,$00,$08
.db $00,$A0,$00,$01
.db $01,$00,$00,$04
.db $FF,$FF
square_env06:
.db $00
.db $00,$08,$00,$04
.db $00,$08,$00,$00
.db $FF,$FF
square_env07:
.db $04
.db $00,$80,$00,$08
.db $00,$80,$00,$02
.db $00,$10,$00,$00
.db $FF,$FF
square_env08:
.db $00
.db $00,$80,$00,$06
.db $FF,$FF
square_env09:
.db $03
.db $00,$80,$00,$08
.db $00,$40,$00,$06
.db $FF,$FF
square_env10:
.db $0A
.db $01,$00,$00,$02
.db $00,$10,$00,$00
.db $FF,$FF
square_env11:
.db $08
.db $01,$00,$10,$07
.db $05,$00,$00,$02
.db $00,$10,$00,$00
.db $FF,$FF
square_env12:
.db $08
.db $01,$00,$06,$07
.db $06,$00,$0C,$01
.db $01,$00,$06,$02
.db $01,$00,$00,$01
.db $FF,$FF
square_env13:
.db $0A
.db $02,$00,$00,$01
.db $04,$00,$00,$04
.db $01,$00,$00,$01
.db $FF,$FF
square_env14:
.db $06
.db $00,$18,$00,$00
.db $FF,$FF
square_env15:

;-----------------------[ Triangle channel instruments ]----------------------
;
; format:   byte 0: hold length
;           byte 1: resvib
;           byte 2: effect
;           byte 3: effect param

RNME_TriangleData:
.db $FF,$00,$00,$00 ; long tone
.db $0A,$00,$00,$00 ; semi-short tone
.db $FF,$00,$04,$72 ; long tone w/ vibrato
.db $04,$00,$00,$00 ; very short tone
.db $06,$00,$02,$60 ; bass drum
.db $12,$00,$02,$20 ; snare drum
.db $14,$00,$00,$00 ; short tone

;-----------------------[ Noise channel instruments ]-------------------------
;
; format:   byte 0-1: ptr to volume envelope (same format as square channel)
;           byte 2: frequency (0-F)
;           byte 3: unused

RNME_NoiseData:
.dw noise_env0 : .db $03,$00  ; closed hihat
.dw noise_env1 : .db $00,$00  ; open hihat
.dw noise_env2 : .db $09,$00  ; "snare"

noise_env0:
.db $0E
.db $06,$00,$00,$00
.db $FF,$FF
noise_env1:
.db $0C
.db $01,$00,$00,$00
.db $FF,$FF
noise_env2:
.db $0C
.db $01,$40,$00,$00
.db $FF,$FF

;----------------------------[ DPCM sample info ]-----------------------------

RNME_DMCDataTable:
.db $07,$34,$A0,$3F     ; C  -> C-1
.db $07,$34,$D0,$3E     ; C# -> C#1
.db $07,$34,$B0,$3F     ; D  -> D-1
.db $08,$34,$D0,$3E     ; C# -> D#1
.db $08,$34,$B0,$3F     ; D  -> E-1
.db $09,$34,$A0,$3F     ; C  -> F-1
.db $0A,$34,$C0,$3F     ; B  -> F#1
.db $0A,$34,$A0,$3F     ; C  -> G-1
.db $0A,$34,$D0,$3E     ; C# -> G#1
.db $0A,$34,$B0,$3F     ; D  -> A-1
.db $0C,$34,$E0,$3E     ; A# -> A#1
.db $0C,$34,$C0,$3F     ; B  -> B-1
.db $0C,$34,$A0,$3F     ; C  -> C-2
.db $0C,$34,$D0,$3E     ; C# -> C#2
.db $0C,$34,$B0,$3F     ; D  -> D-2
.db $0D,$34,$C0,$3F     ; B  -> D#2
.db $0D,$34,$A0,$3F     ; C  -> E-2
.db $0D,$34,$D0,$3E     ; C# -> F-2
.db $0E,$34,$C0,$3F     ; B  -> F#2
.db $0E,$34,$A0,$3F     ; C  -> G-2
.db $0E,$34,$D0,$3E     ; C# -> G#2
.db $0E,$34,$B0,$3F     ; D  -> A-2
.db $0F,$34,$E0,$3E     ; A# -> A#2
.db $0F,$34,$C0,$3F     ; B  -> B-2
.db $0F,$34,$A0,$3F     ; C  -> C-3
.db $0F,$34,$D0,$3E     ; C# -> C#3
.db $0F,$34,$B0,$3F     ; D  -> D-3

.db $0F,$00,$F0,$10     ; bassdrum
.db $0F,$00,$F4,$20     ; combined bassdrum+snare

.end
