.include "huff.h"

.codeseg

.public HuffInit
.public HuffDecodeByte

; HuffDecodeByte
; ==============

    HuffDecodeByte:
    lda     #<HuffTable
    sta     pHuffNode
    lda     #>HuffTable
    sta     pHuffNode+1     ; begin at top of tree
    ldx     HuffCount
  - ldy     #0
    lda     [pHuffNode],y
    beq     ++
    dex
    bpl     +
    ldx     #7              ; reset bit counter
    lda     [pHuffData],y
    sta     HuffInput
    inc     pHuffData
    bne     +
    inc     pHuffData+1
  + asl     HuffInput
    bcc     +
    iny     ; follow right branch
  + lda     [pHuffNode],y   ; relative address of next node
    clc
    adc     pHuffNode
    sta     pHuffNode
    bcc     -
    inc     pHuffNode+1
    bcs     -
 ++ iny
    lda     [pHuffNode],y   ; decoded value
    stx     HuffCount
    rts

; HuffInit
; ========

    HuffInit:
    sta     pHuffData
    sty     pHuffData+1
    lda     #0
    sta     HuffCount
    rts

HuffTable:
.include "huff/huffpuff.tab"

.end
