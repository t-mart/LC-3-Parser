#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TRUE 1
#define FALSE 0

/*
 * Imagine an arbitrary "language" with the following grammar:
 *
 * <form> ::= <name> | N<form> | <binaryoperator><form><form> 
 * <binaryoperator> ::= A | B| C | D 
 * <name> ::= a | b | c | ... | x | y | z 
 *
 * Examples of well-formed forms:
 *
 * a
 * b
 * Nd
 * Bxy
 * CNdApq
 * DBpcCrt
 *
 * So a "name" is a small letter from a to z
 * And a form is either a name or an N followed by a form or any of the letters
 * A, B, C, D followed by two forms
 * So
 * c is a name thus it is a form
 * Nx is a form: Letter N followed by a name which is a form
 * Bxy is a form: Letter B followed by two names which are forms
 * CNdApq is a form: Letter C followed by two forms Nd and Apq
 * etc.
 * 
 * How can we write a program to recognize valid forms?
 * 
 * We use a recursive descent parser
 * 
 * Our program will read a string of character into a buffer. Then it will
 * call functions that will return whether or not the string is a form
 * The isForm function will call various functions including itself to 
 * determine if according to the grammar the string in the buffer is a form.
 * 
 * If the string in the buffer and we are at the end of the string then
 * we have found a valid form.
 */

// Returns true if valid name (a-z) is found in input stream
int isName();

// Returns true if N is found in input stream
int isN();
 
// Returns true if A-D is found in input stream
int isBinaryOperator();
 
// Returns true if a <form> is found
int isForm();
 

char buffer[80];
int ptr;

char *s;

char nl[] = "\n";

int main(int argc, char *argv[])
{
  if (argc > 1) {
    s = strcat(argv[1], nl);
  } else {  

    printf("Enter a candidate well-formed form: ");
	/*
	The fgets function below reads in as many as 80-1 characters and then adds
	a null character to the end of the string of characters read in forming a
	'string' much like the LC-3 .STRINGZ pseudo-op.
	If the user types an 'enter' the '\n' character gets inserted followed by
	the null character.
	YOU DO NOT HAVE TO IMPLEMENT THIS EXACT FUNCTIONALITY!!!
	All you need to do is read characters into a buffer until the user types 
	enter and then process the characters in the buffer.
	*/	
    s = fgets(buffer, 80, stdin);
  }
    ptr = 0;
    if(isForm() && s[ptr]=='\n') 
    {
      if (argc > 1) {
        printf("1\n");
      } else {
        printf("Valid 'well formed form' found\n");
      }
        return 0;
    }
    else
    {
      if (argc > 1) {
        printf("0\n");
        return -1;
      } else {
        printf("Invalid 'well formed form'\n");
        return 0;
      }
    }
}


 
int isName()
{
    if(s[ptr] >= 'a' && s[ptr] <= 'z')
    {
        ptr++;
        return TRUE;
    }
    return FALSE;
}

int isN()
{
    if(s[ptr] == 'N')
    {
        ptr++;
        return TRUE;
    }
    return FALSE;
}

int isBinaryOperator()
{
    if(s[ptr] >= 'A' && s[ptr] <= 'D')
    {
        ptr++;
        return TRUE;
    }
    return FALSE;
}


// <form> ::= <names> | N<form> | A<form><form> | B<form><form> | C<form><form> | D<form><form>
int isForm()
{
    if(isName() || 
       (isN() && isForm()) ||
       (isBinaryOperator() && isForm() && isForm()))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}



