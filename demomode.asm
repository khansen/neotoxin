.include "game.h"

.codeseg

.public PlayDemo
.public RecordDemo

.extrn Area2DMain:proc
.extrn PAL_FadeToBlack:proc
.extrn SetBank:proc

; RecordDemo
; ==========
; Records a game demo, by storing keypresses in RAM for each CPU frame.
; Data is realtime RLE encoded, two bytes per entry: 1st byte is the key
; state itself, 2nd byte is the number of frames that key state has been used.
; Call every frame in the game loop.
; pDemo must point to a valid RAM address where the demo can be stored.

    RecordDemo:
    lda     OldStat
    cmp     JoyStat
    bne     IsNewStat       ; joy status has changed

    inc     JoyCount
    beq     IsNewStat       ; max. 256 repeats of a certain status
    rts

    IsNewStat:
    ldy     #$00
    sta     [pDemo],y       ; record joy status
    inc     pDemo
    bne     +
    inc     pDemo+1
  + lda     JoyCount
    sta     [pDemo],y       ; record # of frames to use status
    inc     pDemo
    bne     +
    inc     pDemo+1
  + lda     JoyStat
    sta     OldStat
    iny     ; =1
    sty     JoyCount
    rts

; PlayDemo
; ========
; Plays a demo.
; pDemo must point to valid key data, stored in the format described above.

    PlayDemo:
    lda     JoyFirst
    bne     StopDemo        ; user pressed a button, stop demo

    dec     JoyCount
    beq     NextStat

    sta     JoyFirst        ; =0, only non-zero 1st frame of each stat
    lda     OldStat
    sta     JoyStat         ; use same stat as last frame
    jmp     Area2DMain      ; run the real game engine

    StopDemo:
    jsr     PAL_FadeToBlack
    lda     #mrTitleInit    ; return to title screen
    sta     MainRoutine
    lda     #0
    jmp     SetBank

    NextStat:
    ldy     #$00
    lda     [pDemo],y
    cmp     #$FF            ; reached end of demo?
    beq     StopDemo
    sta     OldStat
    sta     JoyStat
    sta     JoyFirst
    inc     pDemo
    bne     +
    inc     pDemo+1
  + lda     [pDemo],y
    sta     JoyCount
    inc     pDemo
    bne     +
    inc     pDemo+1
  + jmp     Area2DMain


.end
