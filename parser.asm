; Tim Martin
; 902 396 824

.orig x3000
MAIN

BR GET_CANDIDATE

;constants
PROMPT .STRINGZ "Enter a candidate form: "
BUFFER_ADDR .FILL x4000
NEWLINE .FILL xFFF6 ;negated char code for easy recognition

;show prompt
GET_CANDIDATE
LEA R0, PROMPT
PUTS

;get chars
LD R1, BUFFER_ADDR ;acts a a pointer to the current char to save

GET_ANOTHER_CHAR
GETC
LD R2, NEWLINE ;check against newline
ADD R2, R2, R0
BRZ PROCESS_CANDIDATE ;leave if so
STR R0, R1, #0 ;store if not
ADD R1, R1, #1
BR GET_ANOTHER_CHAR

PROCESS_CANDIDATE


; We suggest that each of your subroutines have a header following
; the format below:

;PRECONDITIONS:
;	
;	
;	
;POSTCONDITIONS:
;	
;	
;	
;<Subroutine Label Goes Here (without semicolon!)
	; your code here

HALT
.end
