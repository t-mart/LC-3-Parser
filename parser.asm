;===========================================================================
;  parser.asm
;  
;  an LC-3 Recursive Decent Parser
;
;  by Tim Martin
;  902 396 824
;  
;  2011-10-19
;===========================================================================

.orig x3000
BR CODE

;constants
PROMPT .STRINGZ "Enter a candidate form: "
BUFFER_ADDR .FILL x4000
NEWLINE .FILL xFFF6 ;negated char code for easy recognition
NEWLINE_POS .FILL xA
INVALID_STRING .STRINGZ "Invalid"
VALID_STRING .STRINGZ "Valid"

TEST_FORM .STRINGZ ""

NAME_FIRST .FILL -97
NAME_LAST .FILL -122
BIN_OP_FIRST .FILL -65
BIN_OP_LAST .FILL -68
N .FILL -78

INPUT_LIMIT .FILL 79
ZERO .FILL 0
ONE .FILL 1

STACK_START .FILL xF000

FALSE .FILL 0
TRUE .FILL 1

;show prompt
CODE
LD R1, BUFFER_ADDR ;acts a a pointer to the current char to save
LD R3, INPUT_LIMIT ;our counter to make sure we're not grabbing too many chars
LD R0, TEST_FORM
BRNP GET_TEST_CANDIDATE

LEA R0, PROMPT
PUTS

;get chars

GET_ANOTHER_CHAR
GETC
LD R2, NEWLINE ;check against newline
ADD R2, R2, R0
BRZ APPEND_NEWLINE ;leave if so
STR R0, R1, 0 ;store if not
ADD R1, R1, 1
ADD R3, R3, -1
BRZ APPEND_NEWLINE
BR GET_ANOTHER_CHAR

GET_TEST_CANDIDATE
LEA R2, TEST_FORM
GET_ANOTHER_TEST_CHAR
LDR R0, R2, 0
BRZ APPEND_NEWLINE
STR R0, R1, 0
ADD R1, R1, 1
ADD R2, R2, 1
ADD R3, R3, -1
BRZ APPEND_NEWLINE
BR GET_ANOTHER_TEST_CHAR

APPEND_NEWLINE
LD R0, NEWLINE_POS
STR R0, R1, 0

PROCESS_CANDIDATE

LD R6, STACK_START
LD R4, BUFFER_ADDR ;r0 is the address of the char

JSR IS_FORM

LDR R0, R6, 0
BRZ INVALID_FORM

LDR R0, R4, 0
LD R1, NEWLINE
ADD R0, R0, R1
BRNP INVALID_FORM

LEA R0, VALID_STRING
BR MSG_LOADED

INVALID_FORM
LEA  R0, INVALID_STRING

MSG_LOADED
PUTS

HALT

;###########################################################################
;  IS_NAME
;
;  returns 0 if buf[ptr] is not a name ('a'-'z'), and 1 if so
;
;  Preconditions:
;  buf[ptr] is the value to be evaluated
;
;  Postconditions:
;  top of stack equals 0 or 1. if 1, ptr incremented
;###########################################################################
IS_NAME
LDR R0, R4, 0

LD R1, NAME_FIRST
ADD R1, R0, R1
BRN NOT_NAME

LD R1, NAME_LAST
ADD R1, R0, R1
BRP NOT_NAME

LD R0, ONE
ADD R4, R4, 1
BR RETURN_NAME

NOT_NAME
LD R0, ZERO

RETURN_NAME
;push name_truth
ADD R6, R6, -1
STR  R0, R6, 0

RET

;###########################################################################
;  IS_N
;
;  returns 0 if buf[ptr] is not an 'N', and 1 if so
;
;  Preconditions:
;  buf[ptr] is the value to be evaluated
;
;  Postconditions:
;  top of stack equals 0 or 1. if 1, ptr incremented
;###########################################################################
IS_N
LDR R0, R4, 0

LD R1, N
ADD R1, R0, R1
BRNP NOT_N

LD R0, ONE
ADD R4, R4, 1
BR RETURN_N

NOT_N
LD R0, ZERO

RETURN_N
;push n truth
ADD R6, R6, -1
STR  R0, R6, 0

RET

;###########################################################################
;  IS_BIN_OP
;
;  returns 0 if buf[ptr] is not a binary operator ('A'-'D'), and 1 if so
;
;  Preconditions:
;  buf[ptr] is the value to be evaluated
;
;  Postconditions:
;  top of stack equals 0 or 1. if 1, ptr incremented
;###########################################################################
IS_BIN_OP
LDR R0, R4, 0

LD R1, BIN_OP_FIRST
ADD R1, R0, R1
BRN NOT_BIN_OP

LD R1, BIN_OP_LAST
ADD R1, R0, R1
BRP NOT_BIN_OP

LD R0, ONE
ADD R4, R4, 1
BR RETURN_BIN_OP

NOT_BIN_OP
LD R0, ZERO

RETURN_BIN_OP
;push bin op truth
ADD R6, R6, -1
STR  R0, R6, 0

RET

;###########################################################################
;  IS_FORM
;
;  returns 0 if buf[ptr] is not the start of a form, 1 otherwise
;
;  Preconditions:
;  buf[ptr] starts a candidate form
;
;  Postconditions:
;  top of stack is 0 or 1
;###########################################################################
IS_FORM
;push ret val and ret addr
ADD R6, R6, -2
STR  R7, R6, 0

;push old fp
ADD R6, R6, -1
STR  R5, R6, 0

;set new fp
ADD R5, R6, -1

;local vars
;truth  IS_NAME       IS_N          IS_BIN_OP
;-----------------------------------------------------------
;1      X             X             form B truth
;0      X             form truth    form A truth 

;allocate truth 0
ADD R6, R6, -1
;allocate truth 1
ADD R6, R6, -1

;code
; {
;     if(isName() || 
;        (isN() && isForm()) ||
;        (isBinaryOperator() && isForm() && isForm()))
;     {
;         return TRUE;
;     }
;     else
;     {
;         return FALSE;
;     }



;=======================TRY IS_NAME=============================
JSR IS_NAME
;pop is name truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ TRY_IS_N

LD R0, ONE
BR RESOLVE_IS_FORM

;=======================TRY IS_N================================
TRY_IS_N
JSR IS_N
;pop is n truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ TRY_IS_BIN_OP

;store n truth in at fp
STR R0, R5, 0

JSR IS_FORM
;pop form truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ TRY_IS_BIN_OP

LD R0, ONE
BR RESOLVE_IS_FORM

;=======================TRY IS_BIN_OP===========================
TRY_IS_BIN_OP
JSR IS_BIN_OP
;pop is bin op truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ RESOLVE_IS_FORM

;store n truth in at fp
STR R0, R5, 0

JSR IS_FORM
;pop form A truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ RESOLVE_IS_FORM

;store n truth in at fp
STR R0, R5, -1

JSR IS_FORM
;pop form A truth
LDR  R0, R6, 0
ADD R6, R6, 1
;is it T or F?
ADD R0, R0, 0
BRZ RESOLVE_IS_FORM

LD R0, ONE
BR RESOLVE_IS_FORM

RESOLVE_IS_FORM
STR R0, R5, 3 ;store ret val

ADD R6, R5, 1 ;pop old locals

;restore old fp
LDR R5, R6, 0
ADD R6, R6, 1

;pop ret addr
LDR  R7, R6, 0
ADD R6, R6, 1 ;sp is now at ret val

;and ret
RET

.END
