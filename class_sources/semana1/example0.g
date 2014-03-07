#header 
<< #include "charptr.h" >>

<<
#include "charptr.c"

int main() {
   ANTLR(expr(), stdin);
}
>>

#lexclass START
#token NUM "[0-9]+"
#token PLUS "\+"
#token MINUS "\-"
#token SPACE "[\ \n]" << zzskip(); >>

expr: NUM ((PLUS|MINUS)^ NUM)* "@" ;

//expr: expr PLUS expr | NUM;

//expr: NUM PLUS expr | NUM;

//expr: NUM | NUM PLUS expr;