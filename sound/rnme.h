.ifndef RNME_H
.define RNME_H

; -------------------------------[ Defines ]----------------------------------

; Zero page state (sound/sequencer.asm)
.extrn RNME_pSong:word
.extrn RNME_pPattern:word
.extrn RNME_pOrder:word
.extrn RNME_pEnvelope:word
.extrn RNME_pPatPtrTable:word
.extrn RNME_Status:byte
.extrn RNME_LoadTune:byte
.extrn RNME_Trigger:byte
.extrn RNME_LastTune:byte
.extrn RNME_SFXStatus:byte
.extrn RNME_pSFX:word
.extrn RNME_Temp1:byte
.extrn RNME_Temp2:byte
.extrn RNME_Temp3:byte

; general channel variables

; All music and sound effect state outside zero page. RNME_InitSong clears
; the whole of rnme_ram, so these arrays are kept together in one struct.
.struc rnme_ram
CHN_OrderPos            .byte[5]
CHN_Pattern             .byte[5]
CHN_PatPos              .byte[5]
CHN_Row                 .byte[5]
CHN_EndRow              .byte[5]
CHN_RowStatus           .byte[5]
CHN_PatLoopCount        .byte[5]
CHN_Speed               .byte[5]
CHN_Tick                .byte[5]
CHN_Transpose           .byte[5]
CHN_pPatternLo          .byte[5]
CHN_pPatternHi          .byte[5]
CHN_pOrderLo            .byte[5]
CHN_pOrderHi            .byte[5]
CHN_OrderRepPos         .byte[5]
CHN_OrderRepCount       .byte[5]
unused0               .byte[6]   ; unused, keeps the original layout
CHN_Note                .byte[3]
CHN_FreqHi              .byte[3]
CHN_ResVib              .byte[3]
CHN_VibDelay            .byte[3]
CHN_VibratoPos          .byte[3]
CHN_SlFreqLo            .byte[3]
CHN_SlFreqHi            .byte[3]
CHN_Effect              .byte[3]
CHN_EffParam            .byte[3]
CHN_EffInfo             .byte[3]
unused1               .byte[8]   ; unused, keeps the original layout
ENV_Index               .byte[4]
ENV_StepLo              .byte[4]
ENV_StepHi              .byte[4]
ENV_Fraction            .byte[4]
ENV_CurrentVol          .byte[4]
ENV_DestVol             .byte[4]
ENV_pLopeLo             .byte[4]
ENV_pLopeHi             .byte[4]
ENV_HoldLength          .byte[4]
ENV_WaveInfo            .byte[4]
ENV_Phase               .byte[4]
ENV_MasterVol           .byte[4]
CHN_Reg0                .byte[4]
CHN_Reg1                .byte[4]
CHN_Reg2                .byte[4]
CHN_Reg3                .byte[4]
CHN_OldReg0             .byte[4]
CHN_OldReg1             .byte[4]
CHN_OldReg2             .byte[4]
CHN_OldReg3             .byte[4]
SQR_DutyDelay           .byte[2]
SQR_DutyCycle           .byte[2]
SFX_Number              .byte[5]
SFX_pDataHi             .byte[5]
SFX_pDataLo             .byte[5]
SFX_Index               .byte[5]
SFX_HoldLength          .byte[5]
.ends

.extrn RNME:rnme_ram          ; sound/sequencer.asm

; Names used throughout the engine for the members of RNME.
CHN_OrderPos            EQU     RNME.CHN_OrderPos
CHN_Pattern             EQU     RNME.CHN_Pattern
CHN_PatPos              EQU     RNME.CHN_PatPos
CHN_Row                 EQU     RNME.CHN_Row
CHN_EndRow              EQU     RNME.CHN_EndRow
CHN_RowStatus           EQU     RNME.CHN_RowStatus
CHN_PatLoopCount        EQU     RNME.CHN_PatLoopCount
CHN_Speed               EQU     RNME.CHN_Speed
CHN_Tick                EQU     RNME.CHN_Tick
CHN_Transpose           EQU     RNME.CHN_Transpose
CHN_pPatternLo          EQU     RNME.CHN_pPatternLo
CHN_pPatternHi          EQU     RNME.CHN_pPatternHi
CHN_pOrderLo            EQU     RNME.CHN_pOrderLo
CHN_pOrderHi            EQU     RNME.CHN_pOrderHi
CHN_OrderRepPos         EQU     RNME.CHN_OrderRepPos
CHN_OrderRepCount       EQU     RNME.CHN_OrderRepCount
CHN_Note                EQU     RNME.CHN_Note
CHN_FreqHi              EQU     RNME.CHN_FreqHi
CHN_ResVib              EQU     RNME.CHN_ResVib
CHN_VibDelay            EQU     RNME.CHN_VibDelay
CHN_VibratoPos          EQU     RNME.CHN_VibratoPos
CHN_SlFreqLo            EQU     RNME.CHN_SlFreqLo
CHN_SlFreqHi            EQU     RNME.CHN_SlFreqHi
CHN_Effect              EQU     RNME.CHN_Effect
CHN_EffParam            EQU     RNME.CHN_EffParam
CHN_EffInfo             EQU     RNME.CHN_EffInfo
ENV_Index               EQU     RNME.ENV_Index
ENV_StepLo              EQU     RNME.ENV_StepLo
ENV_StepHi              EQU     RNME.ENV_StepHi
ENV_Fraction            EQU     RNME.ENV_Fraction
ENV_CurrentVol          EQU     RNME.ENV_CurrentVol
ENV_DestVol             EQU     RNME.ENV_DestVol
ENV_pLopeLo             EQU     RNME.ENV_pLopeLo
ENV_pLopeHi             EQU     RNME.ENV_pLopeHi
ENV_HoldLength          EQU     RNME.ENV_HoldLength
ENV_WaveInfo            EQU     RNME.ENV_WaveInfo
ENV_Phase               EQU     RNME.ENV_Phase
ENV_MasterVol           EQU     RNME.ENV_MasterVol
CHN_Reg0                EQU     RNME.CHN_Reg0
CHN_Reg1                EQU     RNME.CHN_Reg1
CHN_Reg2                EQU     RNME.CHN_Reg2
CHN_Reg3                EQU     RNME.CHN_Reg3
CHN_OldReg0             EQU     RNME.CHN_OldReg0
CHN_OldReg1             EQU     RNME.CHN_OldReg1
CHN_OldReg2             EQU     RNME.CHN_OldReg2
CHN_OldReg3             EQU     RNME.CHN_OldReg3
SQR_DutyDelay           EQU     RNME.SQR_DutyDelay
SQR_DutyCycle           EQU     RNME.SQR_DutyCycle
SFX_Number              EQU     RNME.SFX_Number
SFX_pDataHi             EQU     RNME.SFX_pDataHi
SFX_pDataLo             EQU     RNME.SFX_pDataLo
SFX_Index               EQU     RNME.SFX_Index
SFX_HoldLength          EQU     RNME.SFX_HoldLength


SFX_ROCKETLAUNCH    EQU 1
SFX_METAL           EQU 2
SFX_ROCKETEXPLODE   EQU 6
SFX_PLAYERDIE       EQU 7
SFX_ENEMYEXPLODE    EQU 8
SFX_ENEMYHIT        EQU 9
SFX_LEVELUP         EQU 10
SFX_PLAYERJUMP      EQU 11
SFX_NOISEEXPLODE    EQU 12
SFX_ENERGYBULLET    EQU 13

.endif
