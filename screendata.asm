.charmap "font.tbl"

.codeseg

.public StatusScreenCHR
.public StatusScreenPal
.public TitleData
.public TitleCHR
.public TitlePal
.public TitleSine
.public GameInfoData
.public SelectGameData
.public NewGameString
.public EnterNameData
.public LetterTransTable
.public StatusScreenData
.public DialogScreenData
.public GameOverData
.public GameOverPal
.public GameOverCHR

;----------------------------------[ Data ]-----------------------------------

TitleCHR:
.db 4,6,4,5,6,7
TitleData:
.incbin "data/title.dat"
TitlePal:
.incbin "data/title.pal"
.db $0F,$02,$0F,$0F
.db $0F,$00,$10,$30
.db $0F,$00,$10,$30
.db $0F,$30,$30,$30

TitleSine:
.db 0,0,1,1,1,2,2,2
.db 2,2,2,2,1,1,1,0
.db 0,-0,-1,-1,-1,-2,-2,-2
.db -2,-2,-2,-2,-1,-1,-1,-0

StatusScreenData:
.incbin "data/status2.dat"
StatusScreenPal:
.db $0F,$00,$10,$20
.db $0F,$00,$10,$20
.db $0F,$00,$10,$20
.db $0F,$00,$10,$20
.db $0F,$04,$14,$34
.db $0F,$00,$10,$20
.db $0F,$00,$10,$20
.db $0F,$00,$10,$20
StatusScreenCHR:
.db 126,88,90,90,90,90

GameInfoData:
.db $21,$48,16
.asc "SnowBro Software"
.db $21,$A6,19
.asc "in association with"
.db $22,$08,15
.asc "EFX Enterprises"
.db $22,$6B,11
.asc "presents..."
.db 0

GameOverData:
.db $21,$0C,9
.asc "Game Over"
.db $21,$8C,8
.asc "Continue"
.db $21,$CC,3
.asc "End"
.db 0
GameOverPal:
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
.db $0F,$20,$20,$20
GameOverCHR:
.db 96,88,90,90,90,90

EnterNameData:
.incbin "data/name2.dat"
LetterTransTable:
.db $8A,$8B,$8C,$8D,$8E,$8F,$90,$91,$92,$93,$94,$95,0,0,0,0
.db $96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,$A0,$A1,0,0,0,0
.db $A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,0,0,0,0
.db $AE,$AF,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,0,0,0,0
.db $BA,$BB,$BC,$BD,$80,$81,$82,$83,$84,$85,$86,$87,0,0,0,0
.db $88,$89,$BE,$BF,$C0,$C1,$C2,$C3,$C4,$C6,$00,$FF,0,0,0,0

SelectGameData:
.incbin "data/select22.dat"

DialogScreenData:
.incbin "data/dialog.dat"

NewGameString:
.asc "New Game  "


.end
