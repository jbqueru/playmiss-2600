; Copyright 2022 Jean-Baptiste M. "JBQ" "Djaybee" Queru
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;    http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

	.processor	6502

_TIA_VSYNC	.equ	$00
_TIA_VBLANK	.equ	$01
_TIA_WSYNC	.equ	$02
;_TIA_RSYNC	.equ	$03
_TIA_NUSIZ0	.equ	$04
_TIA_NUSIZ1	.equ	$05
_TIA_COLUP0	.equ	$06
_TIA_COLUP1	.equ	$07
_TIA_COLUPF	.equ	$08
_TIA_COLUBK	.equ	$09
_TIA_CTRLPF	.equ	$0A
_TIA_REFP0	.equ	$0B
_TIA_REFP1	.equ	$0C
_TIA_PF0	.equ	$0D
_TIA_PF1	.equ	$0E
_TIA_PF2	.equ	$0F
_TIA_RESP0	.equ	$10
_TIA_RESP1	.equ	$11
_TIA_RESM0	.equ	$12
_TIA_RESM1	.equ	$13
_TIA_RESBL	.equ	$14
_TIA_AUDC0	.equ	$15
_TIA_AUDC1	.equ	$16
_TIA_AUDF0	.equ	$17
_TIA_AUDF1	.equ	$18
_TIA_AUDV0	.equ	$19
_TIA_AUDV1	.equ	$1A
_TIA_GRP0	.equ	$1B
_TIA_GRP1	.equ	$1C
_TIA_ENAM0	.equ	$1D
_TIA_ENAM1	.equ	$1E
_TIA_ENABL	.equ	$1F
_TIA_HMP0	.equ	$20
_TIA_HMP1	.equ	$21
_TIA_HMM0	.equ	$22
_TIA_HMM1	.equ	$23
_TIA_HMBL	.equ	$24
_TIA_VDELP0	.equ	$25
_TIA_VDELP1	.equ	$26
_TIA_VDELBL	.equ	$27
_TIA_RESMP0	.equ	$28
_TIA_RESMP1	.equ	$29
_TIA_HMOVE	.equ	$2A
_TIA_HMCLR	.equ	$2B
_TIA_CXCLR	.equ	$2C

_TIA_CO_GRAY	.equ	$00
_TIA_CO_GOLD	.equ	$10
_TIA_CO_ORANGE	.equ	$20
_TIA_CO_BRT_ORG	.equ	$30
_TIA_CO_PINK	.equ	$40
_TIA_CO_PURPLE	.equ	$50
_TIA_CO_PUR_BLU	.equ	$60
_TIA_CO_BLU_PUR	.equ	$70
_TIA_CO_BLUE	.equ	$80
_TIA_CO_LT_BLUE	.equ	$90
_TIA_CO_TURQ	.equ	$A0
_TIA_CO_GRN_BLU	.equ	$B0
_TIA_CO_GREEN	.equ	$C0
_TIA_CO_YLW_GRN	.equ	$D0
_TIA_CO_ORG_GRN	.equ	$E0
_TIA_CO_LT_ORG	.equ	$F0

_TIA_LU_MIN	.equ	$0
_TIA_LU_V_DARK	.equ	$2
_TIA_LU_DARK	.equ	$4
_TIA_LU_M_DARK	.equ	$6
_TIA_LU_M_LIGHT	.equ	$8
_TIA_LU_LIGHT	.equ	$A
_TIA_LU_V_LIGHT	.equ	$C
_TIA_LU_MAX	.equ	$E

	.org	$F000,0
Main:
; Set up CPU
	CLD
	LDX	#$FF
	TXS

; Clear zero-page (TIA + RAM)
	LDA	#0
	TAX
Clear:	STA	0,X
	INX
	BNE	Clear

; Set the player/missile graphics pointers
	LDA	#0
	STA	$80
	LDA	#$F1
	STA	$81

Loop:
; -------------------------------
; Overscan - 30 lines total
	STA	_TIA_WSYNC	; overscan line 1
	LDA	#2
	STA	_TIA_VBLANK	; turn display off
	LDY	#29
Overscan:
	STA	_TIA_WSYNC	; overscan line 2-30
	DEY
	BNE	Overscan

; -------------------------------
; Vsync - 3 lines
	STA	_TIA_WSYNC	; vsync line 1
	LDA	#2
	STA	_TIA_VSYNC	; turn sync on
	STA	_TIA_WSYNC	; vsync line 2
	STA	_TIA_WSYNC	; vsync line 3

; -------------------------------
; Vblank - 37 lines total
	STA	_TIA_WSYNC	; vblank line 1
	LDA	#
	STA	_TIA_VSYNC	; turn sync off
	LDY	#34
Vblank:
	STA	_TIA_WSYNC	; vblank line 2-35
	DEY
	BNE	Vblank

; -------------------------------
; Vblank line 36
; Align sprites
	STA	_TIA_WSYNC

	; Start delay code 44 clocks
	LDA	#$0A		; 2 clocks
	; hidden ASL		; 4 * 2 clocks = 8
	NOP			; 5 * 2 clocks
	NOP			; 5 * 2 clocks
	BPL	*-3		; 4 * 3 clocks + 2 = 14
	; End delay code 44 clocks

	STA	_TIA_RESP0
	STA	_TIA_RESM0
	LDA	#_TIA_CO_TURQ+_TIA_LU_MAX
	STA	_TIA_COLUP0
	LDA	#$AA
	STA	_TIA_GRP0
	LDA	#2
	STA	_TIA_ENAM0

	LDA	$80
	CLC
	ADC	#2
	STA	$80
	BCC	DonePtr
	INC	$81
	LDA	#$F3
	CMP	$81
	BNE	DonePtr
	LDA	#$F1
        STA	$81
DonePtr:
; -------------------------------
; Vblank line 37
; Turn display on and start render loop
	STA	_TIA_WSYNC

	; Start delay code 68 clocks
	LDX	#13		; 2 clocks
	DEX			; 13 * 2 clocks = 26
	BNE	*-1		; 12 * 3 clocks + 2 = 38
	NOP			; 2 clocks
	; End delay code 68 clocks

	LDY	#0		; clock 68
	STY	_TIA_VBLANK	; clock 70 - finish on 73

; -------------------------------
; Active lines 1-128
Lines:
	STA	_TIA_WSYNC
	LDA	($80),Y
	STA	_TIA_GRP0
	INY
	LDA	($80),Y
	STA	_TIA_ENAM0
	INY
	BNE	Lines

; -------------------------------
; Active line 129
	STA	_TIA_WSYNC
	LDA	#0
	STA	_TIA_GRP0
	STA	_TIA_ENAM0
	LDY	#63

; -------------------------------
; Active lines 130-192
ExtraLines:
	STA	_TIA_WSYNC
	DEY
	BNE	ExtraLines

; -------------------------------
	JMP	Loop

; The actual graphics
	.org	$F100
Bitmap:
	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11111111,2

	.byte	%11111111,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2

	.byte	0,0
	.byte	0,0

	.byte	%11111111,2
	.byte	%11111111,2
	.byte	%11000000,2
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000010,0
	.byte	%11111110,0

	.byte	%11111110,0
	.byte	%11000010,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%11100000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%11100000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%00011100,0
	.byte	%00111110,0
	.byte	%01110111,0
	.byte	%01100011,0
	.byte	%11100011,2

	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2

	.byte	%01100011,0
	.byte	%01100011,0
	.byte	%01110111,0
	.byte	%00111110,0
	.byte	%00011100,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11001001,2
	.byte	%11001001,2
	.byte	%11001001,2

	.byte	%11011101,2
	.byte	%11011101,2
	.byte	%11111111,2
	.byte	%01110111,0
	.byte	%01100011,0

	.byte	0,0
	.byte	0,0

	.byte	%00011100,0
	.byte	%00111110,0
	.byte	%01110111,0
	.byte	%01100011,0
	.byte	%11100011,2

	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2

	.byte	%01100011,0
	.byte	%01100011,0
	.byte	%01110111,0
	.byte	%00111110,0
	.byte	%00011100,0

	.byte	0,0
	.byte	0,0

	.byte	%11111110,0
	.byte	%11111111,0
	.byte	%11000011,0
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000011,0

	.byte	%11111111,0
	.byte	%11111111,0
	.byte	%11000011,0
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2
	.byte	0,0
	.byte	0,0

	.byte	%11100000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%11111100,0
	.byte	%11111110,0
	.byte	%11000111,0
	.byte	%11000011,0
	.byte	%11000011,2

	.byte	%11000011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000011,2

	.byte	%11000011,0
	.byte	%11000011,0
	.byte	%11000111,0
	.byte	%11111110,0
	.byte	%11111100,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11111111,2

	.byte	%11111111,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2

	.byte	0,0
	.byte	0,0

	.byte	%11111111,2
	.byte	%11111111,2
	.byte	%11000000,2
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000010,0
	.byte	%11111110,0

	.byte	%11111110,0
	.byte	%11000010,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%11100000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%11100000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,0

	.byte	%11000000,0
	.byte	%11000000,0
	.byte	%11000000,2
	.byte	%11111111,2
	.byte	%11111111,2

	.byte	0,0
	.byte	0,0

	.byte	%00011100,0
	.byte	%00111110,0
	.byte	%01110111,0
	.byte	%01100011,0
	.byte	%11100011,2

	.byte	%11100011,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2

	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11000001,2
	.byte	%11100011,2

	.byte	%01100011,0
	.byte	%01100011,0
	.byte	%01110111,0
	.byte	%00111110,0
	.byte	%00011100,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0
	.byte	0,0

; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
