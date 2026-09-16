    ; Luke Groesbeck
    ; RCET3373
    ; Funky Muzak Program
    ; https://github.com/groeluke/Funky-Muzak/tree/main/LAB_4_Part_2_Muzak.X
    
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
  
   indexcount EQU 0x20 ;use data memory address 0x20 as an 8-bit loop counter  
   outcount EQU 0x21 ;use data memory address 0x21 as an 8-bit loop counter
   incount EQU 0x22 ;use data memory address 0x22 as an 8-bit loop counter
 
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
    MOVLW 0xFF
    MOVWF 0x86  ;TRISB set PORTB as inputs for dip switches
    
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
	; main code goes here
	CALL SelectSwitch  ;Determine which switch is active
	
	MOVF indexcount,W  ;Check if no switch is active 
	BTFSC indexcount,7 ;
	GOTO Silent
	
        CALL LookUp         ;Call to the Look up table and check which index is selected
        MOVWF outcount      ;Move the value to outcount for delay to play note
	
	CALL Delay          ;Call delay and play frequency for note selected
	
	MOVLW 0x01          ;Toggle RA0
	XORWF 0x05,1        ;Toggle TA0 
	
	GOTO Main
	
    Silent:
        BCF 0x05,0          ;Force RA0 low silence
	GOTO Main
	
    SelectSwitch:
	BTFSS 0x06,7   ;Skip next line if RB7 is set 
	GOTO Test6     ;If not Test the next switch
	GOTO Set8      ;If RB7 is high got to Set8
	
	Test6:
        BTFSS 0x06,6   ;Skip next line if RB6 is set 
	GOTO Test5     ;If not Test the next switch
	GOTO Set7      ;If RB6 is high got to Set7
	
	Test5:
        BTFSS 0x06,5   ;Skip next line if RB5 is set 
	GOTO Test4     ;If not Test the next switch
	GOTO Set6      ;If RB5 is high got to Set6
	
	Test4:
        BTFSS 0x06,4   ;Skip next line if RB4 is set 
	GOTO Test3     ;If not Test the next switch
	GOTO Set5      ;If RB4 is high got to Set5
	
	Test3:
        BTFSS 0x06,3   ;Skip next line if RB3 is set 
	GOTO Test2     ;If not Test the next switch
	GOTO Set4      ;If RB3 is high got to Set4
	
	Test2:
        BTFSS 0x06,2   ;Skip next line if RB2 is set 
	GOTO Test1     ;If not Test the next switch
	GOTO Set3      ;If RB2 is high got to Set3
	
	Test1:
        BTFSS 0x06,1   ;Skip next line if RB1 is set 
	GOTO Test0     ;If not Test the next switch
	GOTO Set2      ;If RB1 is high got to Set2
	
	Test0:
        BTFSS 0x06,0   ;Skip next line if RB0 is set 
	GOTO NoneSet   ;If not Silence
	GOTO Set1      ;If RB0 is high got to Set1
	
	Set8:
        MOVLW 0x08           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set7:
        MOVLW 0x07           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set6:
        MOVLW 0x06           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set5:
        MOVLW 0x05           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set4:
        MOVLW 0x04           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set3:
        MOVLW 0x03           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        Set2:    
        MOVLW 0x02           ;Select the character set for display 1
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
	Set1:
        MOVLW 0x01           ;Move W into indexcount
	MOVWF indexcount     ;Send W to indextcount for index table
	RETURN               ;Return the indexcount for index table 
	
        NoneSet:
        BSF indexcount,7      ;Send clear indexcount so no noise is made
	RETURN               ;Return the indexcount for index table 
    
    LookUp:
        MOVF indexcount,W
	ADDWF PCL,1 ;ADDWF PCL,F - jump into table below
	
        RETLW 0x00       ;index 0 Silent
        RETLW 0xEE       ;index 1 C3
        RETLW 0xD4       ;index 2 D3
        RETLW 0xBD       ;index 3 E3
        RETLW 0xB2       ;index 4 F3
        RETLW 0x9F       ;index 5 G3
        RETLW 0x8E       ;index 6 A3
        RETLW 0x7E       ;index 7 B3
        RETLW 0x77       ;index 8 C4
    
    Delay:
        OutLoop:
        MOVLW 0x04
        MOVWF incount

        InLoop:
        DECFSZ incount,1
        GOTO InLoop

        DECFSZ outcount,1
        GOTO OutLoop
    
    RETURN
	
    End