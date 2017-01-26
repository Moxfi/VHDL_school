;************************************************************
;*	Esimerkkiohjelma, joka ohjaa LED1:n p‰‰lle ja piippaa	*
;*	piezoa kun SW1 kytkint‰ painetaan						*
;************************************************************
	
	.include	"tn2313def.inc"	;ATtiny2313 ohjaimen rekisterim??rittelyt

	;*** Symbolisten tunnusten ja vakioiden m‰‰rittely
	.equ	SW1  = 2				;SW1 kytkimen I/O-linjan numero
	.equ	LED1 = 0				;LED1:nI I/O-linjan numero
	.equ	PZ	 = 6				;Piezon I/O-linjan numero
	.equ	PIIP_LKM = 3				;Piezon piippausten lukum‰‰r‰
	.equ	KIERROS1 = 255				;Viivelaskurin kierrokset1
	.equ	KIERROS2 = 255				;Viivelaskurin kierrokset2 

	.cseg						;Assembly ohjelmakoodi alkaa t‰st‰
	.org	0x00					;Reset k‰skyn osoite
	RJMP	INIT
;*************************************************
;	P‰‰ohjelma (ks. Esimerkkiohjelman Vuokaavio 1)
;*************************************************
	.org	0x13					;P‰‰ohjelman alkuosoite
INIT:
	;*** Mikro-ohjaimen toimintojen alustus ***
	;*** Pino  ***
	LDI		R30,RAMEND			;Pinon pohja kuntoon, ts. sijoitetaan
	OUT		SPL,R30				;SP:n arvoksi RAM:n viimeinen osoite
	;*** Porttiasetukset ***
	LDI		R30,0xFF			;*** PORTB ***
	OUT		DDRB,R30			;PORTB:n kaikki linjat OUTPUT-tilassa
	OUT		PORTB,R30			;LEDit OFF
								;*** PORTD ***	
	LDI		R30,0b01111100;			;Piezo OFF ja ylˆsvedot ON kytkimien
	OUT		PORTD,R30			;SW1 - SW4 I/O-linjoissa
	LDI		R30,0b01000000;			;PORTD:n 6-linja OUTPUT-tilaan ja
	OUT		DDRD,R30			;0 - 5 linjat INPUT-tilaan

	LDI		R20,PIIP_LKM			;Lukum‰‰r‰laskuri Piezon piippauksille

LOOP:							;P‰‰ohjelman ikuinen ohjelmalooppi
	SBIS	PIND,SW1				;Jos SW1 EI ole painettu,takaisin loopin alkuun
	RCALL	LED_PZ					;Jos SW1 ON painettu, LED1:n ja Piezon ohjaus
	RJMP	LOOP

;**************************************************************
;	LEDin ohjaus ja piezon huudatusaliohjelma (ks. Vuokaavio 2)
;**************************************************************
LED_PZ:
	CBI		PORTB,LED1			;LED1 ON
	CBI		PORTD,PZ			;Piezo ON ja 
	RCALL		VIIVE				;pidet‰‰n sit‰ p‰‰ll‰ VIIVEen ajan
	SBI		PORTD,PZ			;Piezo OFF ja
	RCALL		VIIVE				;pidet‰‰n sit‰ pois p‰‰lt‰ VIIVEen ajan
	DEC		R20					;V‰hennet‰‰n piezon huudatuslaskuria
	BRNE		LED_PZ				;Jos laskuri EI ole nolla, piippaus jatkuu
	SBI		PORTB,LED1			;Jos laskuri ON nolla, se asetetaan alku-
	LDI		R20,PIIP_LKM			;arvoonsa,LED1 OFF ja palataan p‰‰ohjelmaan
	RET


;************************************************************************
;	Viivealiohjelma tekee KIERROS1 x KIERROS2 kierrosta (ks. Vuokaavio 3)
;************************************************************************
VIIVE:							;VIIVE = KIERROS1 x KIERROS2 x 5 x Tkello
	LDI		R17,KIERROS1			;R17 on ulomman silmukan laskuri
JATKA1:	
	LDI		R18,KIERROS2			;R18 on sisemm‰n silmukan laskkuri
JATKA2:							
	NOP						;Jokainen NOP kuluttaa aikaa yhden
	NOP						;kellojakson
	NOP						;Pyˆrit‰n t‰ss‰ silmukassa kunnes
	DEC		R18				;sisempi laskuri R18 = 0
	BRNE	JATKA2
	DEC		R17				;Ulompaan silmukkaan menn‰‰n aina
	BRNE	JATKA1					;kun sisempi silmukka = 0. Kun myˆs
	RET						;R17 = 0, poistutaan VIIVE aliohjelmasta

	.dseg


