.ifndef RNME_H
.define RNME_H

; -------------------------------[ Defines ]----------------------------------

RNME_RAM                EQU     $C0 ; - $D3

; global variables

RNME_pSong              EQU     RNME_RAM
RNME_pPattern           EQU     RNME_RAM+2
RNME_pOrder             EQU     RNME_RAM+4
RNME_pEnvelope          EQU     RNME_RAM+6
RNME_pPatPtrTable       EQU     RNME_RAM+8
RNME_Status             EQU     RNME_RAM+10
RNME_LoadTune           EQU     RNME_RAM+11
RNME_Trigger            EQU     RNME_RAM+12
RNME_LastTune           EQU     RNME_RAM+13
RNME_SFXStatus          EQU     RNME_RAM+14
RNME_pSFX               EQU     RNME_RAM+15
RNME_Temp1              EQU     RNME_RAM+17
RNME_Temp2              EQU     RNME_RAM+18
RNME_Temp3              EQU     RNME_RAM+19

; general channel variables

CHN_OrderPos            EQU     $0700
CHN_Pattern             EQU     $0705
CHN_PatPos              EQU     $070A
CHN_Row                 EQU     $070F
CHN_EndRow              EQU     $0714
CHN_RowStatus           EQU     $0719
CHN_PatLoopCount        EQU     $071E
CHN_Speed               EQU     $0723
CHN_Tick                EQU     $0728
CHN_Transpose           EQU     $072D
CHN_pPatternLo          EQU     $0732
CHN_pPatternHi          EQU     $0737
CHN_pOrderLo            EQU     $073C
CHN_pOrderHi            EQU     $0741
CHN_OrderRepPos         EQU     $0746
CHN_OrderRepCount       EQU     $074B

; chn0-2 only

CHN_Note                EQU     $0756
CHN_FreqHi              EQU     $0759
CHN_ResVib              EQU     $075C
CHN_VibDelay            EQU     $075F
CHN_VibratoPos          EQU     $0762
CHN_SlFreqLo            EQU     $0765
CHN_SlFreqHi            EQU     $0768
CHN_Effect              EQU     $076B
CHN_EffParam            EQU     $076E
CHN_EffInfo             EQU     $0771

; volume envelope info (chn0-3 only)

ENV_Index               EQU     $077C
ENV_StepLo              EQU     $0780
ENV_StepHi              EQU     $0784
ENV_Fraction            EQU     $0788
ENV_CurrentVol          EQU     $078C
ENV_DestVol             EQU     $0790
ENV_pLopeLo             EQU     $0794
ENV_pLopeHi             EQU     $0798
ENV_HoldLength          EQU     $079C
ENV_WaveInfo            EQU     $07A0
ENV_Phase               EQU     $07A4
ENV_MasterVol           EQU     $07A8

; RAM copies of channel regs (chn0-3 only)

CHN_Reg0                EQU     $07AC
CHN_Reg1                EQU     $07B0
CHN_Reg2                EQU     $07B4
CHN_Reg3                EQU     $07B8
CHN_OldReg0             EQU     $07BC
CHN_OldReg1             EQU     $07C0
CHN_OldReg2             EQU     $07C4
CHN_OldReg3             EQU     $07C8

SQR_DutyDelay           EQU     $07CC
SQR_DutyCycle           EQU     $07CE

; sfx info

SFX_Number              EQU     $07D0
SFX_pDataHi             EQU     $07D5
SFX_pDataLo             EQU     $07DA
SFX_Index               EQU     $07DF
SFX_HoldLength          EQU     $07E4


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
