    ; Luke Groesbeck
    ; RCET3373
    ; LAB 3
    ; https://github.com/groeluke/Funky-Muzak/tree/main/LAB_4_Part_1_Muzak.X
    
; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

; config statements should precede project file includes.
#include <xc.inc>
count EQU 0x20 ;use data memory address 0x20 as an 8-bit loop counter 
 
; Reset Vector at 0000h. Execution starts here after reset.
PSECT resetVect,class=CODE,delta=2
ResetVector: 
    goto Setup


; Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2
 
Setup:
    ; add device setup here
    
    ;         Bank 0
    BCF 0x03,6  ;Set Bank 0
    BCF 0x03,5  ;Set Bank 0
    CLRF 0x06   ;Setting PortB on reset low
    CLRF 0x05   ;Setting PortA on reset low
    
    ;         Bank 1
    BCF 0x03,6  ;Set Bank 1
    BSF 0x03,5  ;Set Bank 1
    MOVLW 0x00
    MOVWF 0x85  ;TRISA set PortA as outputs
    MOVLW 0x01
    MOVWF 0x86  ;TRISB set RB0 as input
    
    ;         Bank 2
    BSF 0x03,6  ;Set Bank 2
    BCF 0x03,5  ;Set Bank 2
    BSF 0x09,1  ;Setting Bit 1 High for CM2CON1
    
    ;         Bank 3
    BSF 0x03,6  ;Set Bank 3
    BSF 0x03,5  ;Set Bank 3
    CLRF 0x88   ;Setting the I/O to digital ANSEL PortA
    CLRF 0x89   ;Setting the I/O to digital ANSELH PortB
    
    
    ;Reset to Bank 0
    BCF 0x03,6  ;Set Bank 0
    BCF 0x03,5  ;Set Bank 0
    
    GOTO Main
    

    Main:
        BTFSC 0x06,0     ;Test RBO Skip the next like if button is pressed
	GOTO ButtonUnpressed
        
    ButtonPressed:
        MOVLW 0x01
	XORWF 0x05,1     ;Toggle RA0
	CALL Delay       ;2 Tcy call to delay to cause a delay
	GOTO Main        ;2 Tcy
	
    ButtonUnpressed:
        BCF 0x05,0       ;1 Tcy Force RA0 low - silence
	GOTO Main        ;2 Tcy
	
    Delay:
        MOVLW 0xA3       ;1 Tcy move W 163 to count
	MOVWF count      ;1 Tcy make count 163
	
    DelayLoop:
    DECFSZ count,1        ;1 Tcy if not zero, 2 Tcy if zero
    GOTO DelayLoop       ;2 Tcy runs 163 times before skipping
    Return               ;2 Tcy return to call
    
    End