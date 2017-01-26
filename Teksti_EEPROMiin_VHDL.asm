;********************************************************************************************
;* Harjoitus 9: EEPROM kirjoitus															*
;* Ryhm‰: Riku Ketonen & Timo Katajam‰ki & Antti-Jussi Pitk‰nen
;* Tiedosto: Esim9.asm																		*
;********************************************************************************************
	.include	"tn2313def.inc" ;* ATtiny2313 I/O Rekisterim‰‰ritykset

	.equ		NULL 		= 0
	.equ		EEPROM_OS 	= 0x20

	.cseg	
	.org		0x00
	RJMP		INIT
	.org		0x13			; Ohjelmakoodin alku

INIT:
	LDI			R30,RAMEND		; Pinon pohja kuntoon
	OUT			SPL,R30
	;
	;PORTIT KUNTOON
	;PortB
	LDI			R30,0xFF
	OUT			PORTB,R30		;LEDit OFF
	OUT			DDRB,R30		;PortB:n linjat OUTPUT
	;PortD
	LDI			R30,0b01111100	;0x40
	OUT			PORTD,R30		; 
	LDI			R30,0b01000000
	OUT			DDRD,R30		;
	
	LDI			R16,EEPROM_OS	;EEPROM kirjoitusosoite
	LDI			R30,LOW(2*TEXT)
	LDI			R31,HIGH(2*TEXT)
	RCALL		WR_EEPROM
	LDI			R20,0x55
	OUT			PORTB,R20

LOOP:
	RJMP		LOOP


WR_EEPROM:						;//EEPROM hallintaa
	OUT			EEAR,R16
	LPM			R20,Z
	CPI			R20,0
	BREQ		POIS
	OUT			EEDR,R20
	SBI			EECR,EEMPE
	SBI			EECR,EEPE

EI_OLE_0:
	SBIC		EECR,EEPE
	RJMP 		EI_OLE_0
	INC			R16
	ADIW		R30,1
	RJMP		WR_EEPROM

POIS:
	RET
	
;EEPROMiin kirjoitettava teksti

TEXT:
	.db			'R','i','k','u',' ','A','n','t','t','i','-','J','u','s','s','i',' ','T','i','m','o',NULL




