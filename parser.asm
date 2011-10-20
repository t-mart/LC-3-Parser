;===========================================================================
;  parser.asm
;  
;  an LC-3 Recursive Decent Parse
;
;  by Tim Martin
;  902 396 824
;  
;  2011-10-19
;===========================================================================

.orig x3000
MAIN

BR GET_CANDIDATE

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
GET_CANDIDATE
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
LD R0, BUFFER_ADDR ;r0 is the address of the char
LDR R1, R0, 0 ;r1 is that char

JSR ISFORM

ADD R2, R2, 0
BRP VALID
INVALID_FORM
LEA R0, INVALID_STRING
PUTS
BR EXIT

VALID
LEA R0, VALID_STRING
PUTS

EXIT
HALT

;  ISFORM
; ===========================================================================
;  determines if the current form is valid
;  the whole kitten kaboodle
;  <form> ::= <name> | N<form> | <BinaryOperator><form><form>
;  <BinaryOperator> ::= A | B | C | D
;  <name> ::= a | b | c | ... | x | y | z
;
;
;  PRE              ->          POST
;  R0: R0 before -> R0 after
;  R1: R1 before -> R1 after
;  R2: R2 before -> R2 after
;  R3: R3 before -> R3 after
;  R4: R4 before -> R4 after
;  R5: R5 before -> R5 after
;  R6: R6 before -> R6 after
;  R7: R7 before -> R7 after
;============================================================================

ISFORM

;set up stack
ADD R6, R6, -1 ;allocate for ret val

ADD R6, R6, -1  ;allocate for ret addr
STR R7, R6, 0 ;push ret addr

ADD R6, R6, -1 ;allocate for fp
STR R5, R6, 0 ;push fp

ADD R5, R6, 0 ;make new fp (which is same as sp bc there are no locals)

;determine if name form
LD R2, NAME_FIRST
ADD R2, R2, R1
BRN TEST_N_FORM

LD R2, NAME_LAST
ADD R2, R2, R1
BRP TEST_N_FORM

BR GOOD_FORM

;determine if N form
TEST_N_FORM
LD R2, N
ADD R2, R2, R1
BRNP TEST_BIN_OP_FORM

ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, -1
BRN TEST_BIN_OP_FORM

BR GOOD_FORM

;determine if binary operator form
TEST_BIN_OP_FORM
LD R2, BIN_OP_FIRST
ADD R2, R2, R1
BRN NOT_FORM

LD R2, BIN_OP_LAST
ADD R2, R2, R1
BRP NOT_FORM

;determine form 1
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, -1
BRN NOT_FORM

;determine form 2
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, -1
BRN NOT_FORM


GOOD_FORM
LD R2, TRUE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

STR R2, R5, 2 ;copy truth into retval

LDR R5, R6, 0 ;pop old fp
ADD R6, R6, 1

LDR R7, R6, 0 ;pop old ret addr
ADD R6, R6, 1

ADD R6, R6, 1
RET

NOT_FORM
LD R2, FALSE
LEA R7, INVALID_FORM ;YOU....SHALL....NOT.....PASS
RET


;  ISNAME
; ===========================================================================
;  determines if the current char is name
;  <name>
;
;  PRE              ->          POST
;  R0: buffer addr -> buffer addr +1
;  R1: buffer char -> buffer char +1
;  R2: R2 before -> truth value of buffer char being a name form
;============================================================================
ISNAME
;determine name
LD R2, NAME_FIRST
ADD R2, R2, R1
BRN ISNAME_FALSE

LD R2, NAME_LAST
ADD R2, R2, R1
BRP ISNAME_FALSE

LD R2, TRUE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET

ISNAME_FALSE
LD R2, FALSE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET

;  ISN
; ===========================================================================
;  determines if the current char is an N form
;  N<form>
;
;  PRE              ->          POST
;  R0: buffer addr -> buffer addr +1
;  R1: buffer char -> buffer char +1
;  R2: R2 before -> truth value of buffer char being a N form
;============================================================================
ISN
;determine N
LD R2, N
ADD R2, R2, R1
BRNP ISN_FALSE

;determine form
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, #-1
BRN ISN_FALSE

LD R2, TRUE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET

ISN_FALSE
LD R2, FALSE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET

;  ISBINOP
; ===========================================================================
;  determines if the current char is a binary operator
;  <BinaryOperator><form><form>
;
;  PRE              ->          POST
;  R0: buffer addr -> buffer addr +1
;  R1: buffer char -> buffer char +1
;  R2: R2 before -> truth value of buffer char being a binary operator form
;============================================================================
ISBINOP
;determine bin op
LD R2, BIN_OP_FIRST
ADD R2, R2, R1
BRN ISBINOP_FALSE

LD R2, BIN_OP_LAST
ADD R2, R2, R1
BRP ISBINOP_FALSE

;determine form 1
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, -1
BRN ISBINOP_FALSE

;determine form 2
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char

JSR ISFORM
ADD R2, R2, -1
BRN ISBINOP_FALSE

LD R2, TRUE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET

ISBINOP_FALSE
LD R2, FALSE
ADD R0, R0, 1 ;increment buffer addr
LDR R1, R0, 0 ;set r1 to next char
RET
.end
