.include "rnme.h"

.codeseg

.public RNME_PlaySong

.extrn RNME_SongPtrTable:label
.extrn RNME_SFXPtrTable:label
.extrn BitMaskTable:label
.extrn RNME_SetFreq:proc
.extrn RNME_FreqTabLo:label
.extrn RNME_FreqTabHi:label
.extrn RNME_DMCDataTable:label
.extrn ENV_Update:proc
.extrn RNME_VolTable:label
.extrn RNME_ChnOffset:label
.extrn GoRoutine:proc
.extrn Return:proc
.extrn RNME_DoSlideUp:proc
.extrn RNME_DoSlideDown:proc
.extrn RNME_DoSlideNote:proc
.extrn RNME_DoVibrato:proc
.extrn RNME_DoArpeggio:proc
.extrn RNME_TriangleData:label
.extrn RNME_SquareData:label
.extrn RNME_NoiseData:label

; ---------------------------------[ Code ]-----------------------------------

;-----------------------------------------------------------------------------
; RNME_InitSong - call once per song
;-----------------------------------------------------------------------------

    RNME_InitSong:
; set up pointer to song data
    asl
    tax
    lda     RNME_SongPtrTable,x
    sta     RNME_pSong
    lda     RNME_SongPtrTable+1,x
    sta     RNME_pSong+1

; clear out entire music RAM
    lda     #0
    tay
  - sta     $0700,y
    iny
    bne     -

; set up ptr to order table for each channel
; initialize some other variables
    ldy     #$00                    ; reset header index
    ldx     #$00                    ; start with channel 0
    RNME_InitChannel:
    inc     CHN_PatLoopCount,x  ; =1
    inc     CHN_EndRow,x    ; =1
    lda     [RNME_pSong],y
    sta     CHN_pOrderLo,x
    iny
    lda     [RNME_pSong],y
    sta     CHN_pOrderHi,x
    iny
    lda     [RNME_pSong],y
    sta     CHN_Speed,x
    sta     CHN_Tick,x
    dec     CHN_Tick,x              ; Tick = Speed - 1
    iny
    inx                             ; next channel
    cpx     #$05                    ; done all channels yet (0..4)?
    bne     RNME_InitChannel

; get pointer to song's pattern pointer table
    lda     [RNME_pSong],y
    sta     RNME_pPatPtrTable
    iny
    lda     [RNME_pSong],y
    sta     RNME_pPatPtrTable+1

; init some sound regs
    ldx     #$03
  - lda     #$08
    sta     CHN_Reg1,x
    sta     CHN_Reg3,x
    lda     #$F0
    sta     ENV_MasterVol,x
    dex
    bpl     -

    jsr     RNME_ClearHardwareRegs

; force all channels to be updated 1st time player is called
    lda     #$0F
    sta     RNME_Trigger

    lda     #0
    sta     RNME_SFXStatus

; enable channels 0-3 (chn 4 must be enabled at each sample trigger)
    lda     #%00001111
    sta     $4015

; set the "music = playing" flag
    lda     #$01
    sta     RNME_Status
    rts

    RNME_ClearHardwareRegs:
    ldy     #$0F
    lda     #$00
  - sta     $4000,y
    dey
    bpl     -
    rts

;-----------------------------------------------------------------------------
; RNME_PlaySong - call every NMI
;-----------------------------------------------------------------------------

    RNME_PlaySong:
    ldy     RNME_LoadTune
    beq     RNME_NoNewSong
    cpy     #$FF
    bne     +
; stop playing current song
    iny
    sty     RNME_LoadTune
    jmp     RNME_StopPlaying
; Y contains the song to start playing, plus 1
  + sty     RNME_LastTune
    lda     #$00
    sta     RNME_LoadTune
    dey
    tya
    jmp     RNME_InitSong

    RNME_NoNewSong:
    ldx     #$04                    ; channel loop counter
    RNME_ChannelLoop:
;;;;;;;;;;;;;   BEGIN SFX CODE
; check for new sfx
    ldy     SFX_Number,x
    beq     RNME_NoSFXTrigger
; load sfx
    dey
    tya
    asl
    tay
    lda     RNME_SFXPtrTable,y
    sta     SFX_pDataLo,x
    iny
    lda     RNME_SFXPtrTable,y
    sta     SFX_pDataHi,x
    lda     #$00
    sta     SFX_Number,x
    sta     SFX_Index,x
    lda     #$01
    sta     SFX_HoldLength,x
    lda     BitMaskTable,x
    ora     RNME_SFXStatus
    sta     RNME_SFXStatus

    RNME_NoSFXTrigger:
    lda     BitMaskTable,x
    and     RNME_SFXStatus      ; sfx playing?
    beq     RNME_UpdateMusic    ; branch if not
; update SFX
    dec     SFX_HoldLength,x
    beq     RNME_UpdateSFX
    jmp     RNME_UpdateMusic

    RNME_UpdateSFX:
    lda     SFX_pDataLo,x
    sta     RNME_pSFX
    lda     SFX_pDataHi,x
    sta     RNME_pSFX+1
    ldy     SFX_Index,x
    lda     [RNME_pSFX],y
    bne     +
; end sfx
    lda     BitMaskTable,x
    eor     RNME_SFXStatus
    sta     RNME_SFXStatus       
    lda     BitMaskTable,x
    ora     RNME_Trigger
    sta     RNME_Trigger
    jmp     RNME_UpdateMusic
  + sta     SFX_HoldLength,x
    iny
    txa
    asl
    asl
    tax
    lda     [RNME_pSFX],y
    sta     $4000,x
    iny
    lda     [RNME_pSFX],y
    sta     $4001,x
    iny
    lda     [RNME_pSFX],y
    sta     $4002,x
    iny
    lda     [RNME_pSFX],y
    sta     $4003,x
    iny
    txa
    lsr
    lsr
    tax
    tya
    sta     SFX_Index,x
;;;;;;;;;;;;    END SFX CODE
    RNME_UpdateMusic:
    lda     RNME_Status
    bne     RNME_MaybeUpdateChannel
    jmp     RNME_NextChannel

    RNME_MaybeUpdateChannel:
    lda     CHN_pOrderHi,x
    bne     RNME_UpdateChannel       ; if ptr is non-zero, update channel
    jmp     RNME_NextChannel         ; else channel is not in use, skip

    RNME_UpdateChannel:
    inc     CHN_Tick,x
    lda     CHN_Tick,x
    cmp     CHN_Speed,x
    beq     RNME_UpdateRow           ; new row when Tick = Speed
    jmp     RNME_NextChannel

    RNME_UpdateRow:
    lda     #0
    sta     CHN_Tick,x              ; reset tick
    inc     CHN_Row,x               ; advance to next row
    lda     CHN_Row,x
    cmp     CHN_EndRow,x            ; reached end of pattern?
    beq     RNME_BeginNewPat
    jmp     RNME_NoNewPat

    RNME_BeginNewPat:
    lda     #$00
    sta     CHN_Row,x               ; reset row
    sta     CHN_PatPos,x            ; reset pattern position
    dec     CHN_PatLoopCount,x
    beq     RNME_AdvanceOrder
; play same pattern again (loop)
    inc     CHN_PatPos,x            ; skip the pattern length byte
    jmp     RNME_NoNewPat

    RNME_AdvanceOrder:
    sta     CHN_Transpose,x         ; default = no transpose
    lda     CHN_pOrderLo,x
    sta     RNME_pOrder
    lda     CHN_pOrderHi,x
    sta     RNME_pOrder+1

    RNME_LoadOrder:
    jsr     RNME_GetOrderByte
    bmi     RNME_OrderSpecial        ; special case if bit 7 set

    inc     CHN_PatLoopCount,x      ; prepare to play pattern once

    RNME_LoadPattern:
    asl
    tay
    lda     [RNME_pPatPtrTable],y    ; get low pointer to pattern
    sta     CHN_pPatternLo,x
    sta     RNME_pPattern
    iny
    lda     [RNME_pPatPtrTable],y    ; get high pointer to pattern
    sta     CHN_pPatternHi,x
    sta     RNME_pPattern+1

    jsr     RNME_GetPatByte          ; get one byte from the pattern
    sta     CHN_EndRow,x            ; this is the pattern length (in rows)
    jmp     RNME_CheckRowStat

    RNME_OrderSpecial:
    cmp     #$FB
    beq     RNME_SetOrderRepeat
    cmp     #$FC
    beq     RNME_CheckOrderRepeat
    cmp     #$FD
    beq     RNME_TransPat            ; $FD = set pattern transpose
    cmp     #$FE
    beq     RNME_GoOrderPos          ; $FE = jump to new order position
    bcs     RNME_StopPlaying         ; $FF = stop playing the track

    and     #$7F                    ; pattern loopcount in bit 0-6
    sta     CHN_PatLoopCount,x
    jsr     RNME_GetOrderByte        ; get pattern to loop
    bpl     RNME_LoadPattern         ; branch always

    RNME_SetOrderRepeat:
    jsr     RNME_GetOrderByte
    sta     CHN_OrderRepCount,x
    lda     CHN_OrderPos,x
    sta     CHN_OrderRepPos,x
    jmp     RNME_LoadOrder

    RNME_CheckOrderRepeat:
    dec     CHN_OrderRepCount,x
    beq     RNME_LoadOrder
    lda     CHN_OrderRepPos,x
    sta     CHN_OrderPos,x
    jmp     RNME_LoadOrder

    RNME_TransPat:
    jsr     RNME_GetOrderByte
    sta     CHN_Transpose,x
    jmp     RNME_LoadOrder

    RNME_GoOrderPos:
    iny
    lda     [RNME_pOrder],y          ; order position to jump to
    sta     CHN_OrderPos,x
    bpl     RNME_LoadOrder           ; branch always

    RNME_StopPlaying:
    lda     #$00
    sta     RNME_Status              ; turn off music
    jmp     RNME_ClearHardwareRegs

    RNME_NoNewPat:
    lda     CHN_pPatternLo,x
    sta     RNME_pPattern
    lda     CHN_pPatternHi,x
    sta     RNME_pPattern+1

    RNME_CheckRowStat:
    lda     CHN_Row,x
    and     #$07
    bne     +
; the next byte in the pattern buffer contains the row status
; for the next eight (8) rows
    pha
    jsr     RNME_GetPatByte
    sta     CHN_RowStatus,x
    pla
  + tay
    lda     BitMaskTable,y
    and     CHN_RowStatus,x
    bne     RNME_ProcessRow
    jmp     RNME_NextChannel

    RNME_ProcessRow:
    jsr     RNME_GetPatByte          ; get byte from pattern
    bpl     RNME_IsNote              ; if bit 7 clear, it's a note #

    cmp     #$E0                    ; is it a command?
    bcc     RNME_IsAppend
    cmp     #$E8
    and     #$07
    bcs     RNME_IsCommand
    sta     CHN_Effect,x
    beq     RNME_ProcessRow
    jsr     RNME_GetPatByte
    sta     CHN_EffParam,x
    jmp     RNME_ProcessRow
    RNME_IsCommand:
    jsr     RNME_GoCommand
    jmp     RNME_ProcessRow

    RNME_IsAppend:
    and     #$7F                    ; note # in lower 7 bits
    bpl     RNME_SetNote             ; skip the volume & vibrato retrig

    RNME_IsNote:
    pha
    lda     RNME_Trigger
    ora     BitMaskTable,x
    sta     RNME_Trigger
    pla

    cpx     #$03                    ; check which channel we are on
    beq     RNME_PlayNoise           ; special case if noise
    bcs     RNME_PlayDPCM            ; or if DPCM

    pha
    lda     #$80
    sta     ENV_Phase,x             ; volume envelope phase = init
    lda     #$00
    sta     CHN_VibratoPos,x        ; reset vibrato position
    lda     CHN_ResVib,x
    sta     CHN_VibDelay,x          ; reset vibrato delay
    pla

    RNME_SetNote:
    adc     CHN_Transpose,x         ; add transpose to note
    ldy     CHN_Effect,x
    cpy     #$03                    ; if slide parameter present...
    beq     RNME_InitSlide          ; ... slide from old to new note
; no slide, set new frequency immediately
    sta     CHN_Note,x
    jsr     RNME_SetFreq

    cpx     #$02
    beq     RNME_TurnOnTri

    lda     ENV_WaveInfo,x
    and     #$C0
    sta     SQR_DutyCycle,x
    lda     ENV_WaveInfo,x
    and     #$0F
    sta     SQR_DutyDelay,x
    bpl     RNME_NextChannel        ; branch always

    RNME_TurnOnTri:
    lda     ENV_HoldLength+2
    sta     ENV_WaveInfo+2          ; reset triangle channel timer
    lda     #$FF
    sta     CHN_Reg0+2             ; enable triangle channel
    bmi     RNME_NextChannel        ; branch always

    RNME_InitSlide:
    cmp     CHN_Note,x              ; CF = slide direction (0=down,1=up)
    sta     CHN_Note,x
    tay
    lda     RNME_FreqTabLo,y
    sta     CHN_SlFreqLo,x
    lda     RNME_FreqTabHi,y
    sta     CHN_SlFreqHi,x

    lda     #$40
    rol
    sta     CHN_EffInfo,x
    jmp     RNME_NextChannel

    RNME_PlayNoise:
    jsr     RNME_SetNoiseInstr
    lda     #$80
    sta     ENV_Phase,x             ; phase = init
    bne     RNME_NextChannel         ; branch always

    RNME_PlayDPCM:
    cmp     #$1B
    bcs     +                       ; no transpose on drum samples
    adc     CHN_Transpose,x
  + asl
    asl
    tay
    lda     RNME_DMCDataTable,y
    sta     $4010                   ; write sample frequency
    lda     RNME_DMCDataTable+1,y
    sta     $4011                   ; write initial delta value
    lda     RNME_DMCDataTable+2,y
    sta     $4012                   ; write sample address
    lda     RNME_DMCDataTable+3,y
    sta     $4013                   ; write sample length
    lda     #$0F
    sta     $4015                   ; turn bit 4 off...
    lda     #$1F
    sta     $4015                   ; ... then on again

    RNME_NextChannel:
    dex                             ; done all channels?
    bmi     +
    jmp     RNME_ChannelLoop         ; if not, do another

; update noise channel
  + lda     RNME_Status
    bne     +
    rts
  + ldx     #$03
    jsr     ENV_Update
; set the channel volume and frequency
    lda     ENV_MasterVol+3
    ora     ENV_CurrentVol+3
    tay
    lda     RNME_VolTable,y
    sta     CHN_Reg0+3             ; set volume
    lda     ENV_WaveInfo+3          ; set frequency
    sta     CHN_Reg2+3

; update triangle channel
    dex
    ldy     ENV_WaveInfo+2
    beq     +                       ; branch if channel not active
    jsr     RNME_DoEffect
; set the channel frequency
    lda     CHN_FreqHi+2
    ora     #$08
    sta     CHN_Reg3+2
    ldy     ENV_WaveInfo+2
    cpy     #$FF                    ; timer = $FF?
    beq     +                       ; if so, no release
    dec     ENV_WaveInfo+2          ; decrement timer
    bne     +                       ; branch if timer not expired
    lda     #$00
    sta     CHN_Reg0+2             ; mute triangle channel
    dex

; update square channels
  - jsr     ENV_Update
    jsr     RNME_DoEffect
    lda     SQR_DutyDelay,x
    beq     RNME_SetSquareVol
    dec     SQR_DutyDelay,x
    bne     RNME_SetSquareVol
    lda     ENV_WaveInfo,x
    asl
    asl
    and     #$C0
    sta     SQR_DutyCycle,x
; set the channel volume and frequency
    RNME_SetSquareVol:
    lda     ENV_MasterVol,x
    ora     ENV_CurrentVol,x
    tay
    lda     RNME_VolTable,y
    ora     SQR_DutyCycle,x
    sta     CHN_Reg0,x              ; set wave info & volume
    lda     CHN_FreqHi,x
    ora     #$08
    sta     CHN_Reg3,x
  + dex
    bpl     -

; write to sound hardware regs
    ldx     #$00
  - lda     BitMaskTable,x  ;
    and     RNME_SFXStatus      ;
    bne     RNME_WriteNextChn   ; don't write if playing sfx
    ldy     RNME_ChnOffset,x
    lsr     RNME_Trigger
    bcc     +
; new note trigger, write to all regs
    lda     CHN_Reg0,x
    sta     CHN_OldReg0,x
    sta     $4000,y
    lda     CHN_Reg1,x
    sta     CHN_OldReg1,x
    sta     $4001,y
    lda     CHN_Reg2,x
    sta     CHN_OldReg2,x
    sta     $4002,y
    lda     CHN_Reg3,x
    sta     CHN_OldReg3,x
    sta     $4003,y
    jmp     RNME_WriteNextChn
  + lda     CHN_Reg0,x
    cmp     CHN_OldReg0,x
    beq     +
    sta     CHN_OldReg0,x
    sta     $4000,y
  + lda     CHN_Reg1,x
    cmp     CHN_OldReg1,x
    beq     +
    sta     CHN_OldReg1,x
    sta     $4001,y
  + lda     CHN_Reg2,x
    cmp     CHN_OldReg2,x
    beq     +
    sta     CHN_OldReg2,x
    sta     $4002,y
  + lda     CHN_Reg3,x
    cmp     CHN_OldReg3,x
    beq     RNME_WriteNextChn
    sta     CHN_OldReg3,x
    sta     $4003,y
    RNME_WriteNextChn:
    inx
    cpx     #$04
    bne     -
    lsr     RNME_Trigger
    rts

;
; RNME_DoEffect
;

    RNME_DoEffect:
    lda     CHN_Effect,x
    jsr     GoRoutine

.db >(Return-1),            <(Return-1)
.db >(RNME_DoSlideUp-1),     <(RNME_DoSlideUp-1)
.db >(RNME_DoSlideDown-1),   <(RNME_DoSlideDown-1)
.db >(RNME_DoSlideNote-1),   <(RNME_DoSlideNote-1)
.db >(RNME_DoVibrato-1),     <(RNME_DoVibrato-1)
.db >(RNME_DoArpeggio-1),    <(RNME_DoArpeggio-1)

;
; RNME_GetPatByte
;

    RNME_GetPatByte:
    ldy     CHN_PatPos,x
    inc     CHN_PatPos,x
    lda     [RNME_pPattern],y
    rts

;
; RNME_GetOrderByte
;

    RNME_GetOrderByte:
    ldy     CHN_OrderPos,x
    inc     CHN_OrderPos,x
    lda     [RNME_pOrder],y
    rts

;
; RNME_GoCommand
;

    RNME_GoCommand:
    jsr     GoRoutine

.db >(RNME_SetInstr-1),          <(RNME_SetInstr-1)     ; $E8
.db >(RNME_SetRelease-1),        <(RNME_SetRelease-1)   ; $E9
.db >(RNME_SetSpeed-1),          <(RNME_SetSpeed-1)     ; $EA
.db >(RNME_SetMasterVol-1),      <(RNME_SetMasterVol-1) ; $EB

;
; RNME_SetInstr
;

    RNME_SetInstr:
    jsr     RNME_GetPatByte
    asl
    asl
    cpx     #$02
    bcc     RNME_SetSquareInstr
; the command is received on the triangle channel
    tay
    lda     RNME_TriangleData+0,y
    sta     ENV_HoldLength+2
    lda     RNME_TriangleData+1,y
    sta     CHN_ResVib+2
    lda     RNME_TriangleData+2,y
    sta     CHN_Effect+2
    lda     RNME_TriangleData+3,y
    sta     CHN_EffParam+2
    rts

; the command is received on a square channel
    RNME_SetSquareInstr:
    asl                     ; each instrument is 8 bytes long
    tay
    lda     RNME_SquareData+0,y
    sta     ENV_pLopeLo,x
    lda     RNME_SquareData+1,y
    sta     ENV_pLopeHi,x
    lda     RNME_SquareData+2,y
    sta     ENV_WaveInfo,x
    lda     RNME_SquareData+3,y
    sta     CHN_ResVib,x
    lda     RNME_SquareData+4,y
    sta     CHN_Effect,x
    lda     RNME_SquareData+5,y
    sta     CHN_EffParam,x
    rts

    RNME_SetNoiseInstr:
    asl
    asl                     ; each instrument is 4 bytes long
    tay
    lda     RNME_NoiseData+0,y
    sta     ENV_pLopeLo+3
    lda     RNME_NoiseData+1,y
    sta     ENV_pLopeHi+3
    lda     RNME_NoiseData+2,y
    sta     ENV_WaveInfo+3
    rts

    RNME_SetRelease:
    cpx     #$02
    bcc     RNME_SetSquareRelease
; the command is received on the triangle channel
    lda     #$01
    sta     ENV_WaveInfo+2
    rts

; the command is received on a square channel
    RNME_SetSquareRelease:
    lda     #$01
    sta     ENV_HoldLength,x
    rts

    RNME_SetSpeed:
    jsr     RNME_GetPatByte
    sta     CHN_Speed,x
    rts

    RNME_SetMasterVol:
    jsr     RNME_GetPatByte
    sta     ENV_MasterVol,x
    rts

.end
