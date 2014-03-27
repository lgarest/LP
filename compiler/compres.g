#header
<<
#include <string>
#include <iostream>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
>>

<<
#include <cstdlib>
#include <cmath>
#include <map>

//global structures
typedef map<string,int> lista_compra;
typedef map<string, lista_compra> lista_ids;
lista_ids m;
AST *root;


// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == ID) {
    attr->kind = "id";
    attr->text = text;
  }
  else if(type == NUM){
    attr->kind = "";
    attr->text = text; 
  }
  else {
    attr->kind = text;
    attr->text = "";
  }
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// create a new "list" AST node with one element
AST* createASTlist(AST *child) {
  AST *as=new AST;
  as->kind="list";
  as->right=NULL;
  as->down=child;
  return as;
}

AST *findASTCompraDef(string id) {
  AST *n = root->down;
  while (n != NULL and (n->kind != "=" or n->down->text != id)) n = n->right;
  if (id != n->down->text) 
    cout << "MISMATCH: " << id << " " << n->down->text << endl;
  return n;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a,int n) {
  AST *c=a->down;
  for (int i=0; c!=NULL && i<n; i++) c=c->right;
  return c;
}

/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a,string s) {
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") {
    if (a->kind != "") cout<<"("<<a->text<<")";
    else cout << a->text;
  }
  cout<<endl;

  AST *i = a->down;
  while (i!=NULL && i->right!=NULL) {
    cout<<s+"  \\__";
    ASTPrintIndent(i,s+"  |"+string(i->kind.size()+i->text.size(),' '));
    i=i->right;
  }
  
  if (i!=NULL) {
      cout<<s+"  \\__";
      ASTPrintIndent(i,s+"   "+string(i->kind.size()+i->text.size(),' '));
      i=i->right;
  }
}

/// print AST 
void ASTPrint(AST *a) {
  while (a!=NULL) {
    cout<<" ";
    ASTPrintIndent(a,"");
    a=a->right;
  }
}

//////////////////////////////////////////////////////////////////////////////
// EVALUATE
//////////////////////////////////////////////////////////////////////////////
int evaluate(AST *a) {
  /*if (a == NULL) return 0;
  else if (a->kind == "+") return evaluate(child(a,0)) + evaluate(child(a,1));
  else if (a->kind == "-") return evaluate(child(a,0)) - evaluate(child(a,1));
  else if (a->kind == "*") return evaluate(child(a,0)) * evaluate(child(a,1));
  else if (a->kind == "/") return evaluate(child(a,0)) / evaluate(child(a,1));
  return atoi(a->text.c_str());*/

}

//////////////////////////////////////////////////////////////////////////////
// EXECUTE
//////////////////////////////////////////////////////////////////////////////
void execute(AST *als) {
  cout << "execute" << endl;
  if (als==NULL) return;
  else{
    cout << "-"<< als->kind << endl;
  }
  execute(als->right);
  /*if (als == NULL) return;
  else if (als->kind == "=") m[child(als,0)->text] = evaluate(child(als,1));
  else if (als->kind == "write") cout << m[child(als,0)->text] << endl;
  else cout << evaluate(child(als,0)) << evaluate(child(als,1)) << endl;
  execute(als->right);*/
}

void assignation(string id, AST *als){
  while (als != NULL){
    m[id][als->down->text] = atoi(als->text.c_str());
    als = als->right;
  }
}

void operation(string id, AST *als){
  cout << "______(operation) als->text,als->kind "<<als->text<<","<<als->kind<<endl;
  if (als->right == NULL and als->down == NULL) return;
  else if(als->right == NULL and als->down != NULL){
      cout << "llamada_down" << endl;
      operation(id, als->down);
      cout << "llamada_down DONE" << endl;
  }
  else if(als->right != NULL and als->down == NULL){

      cout << "llamada_right" << endl;
      operation(id, als->right);
      cout << "llamada_right DONE" << endl;
  }
  else if(als->down != NULL and als->right != NULL){
    cout << "llamada_down" << endl;
    operation(id, als->down);
    cout << "llamada_right" << endl;
    operation(id, als->right);
  }
  // RECUR OVER
  cout << "___ text,kind: " << als->text <<","<<als->kind << endl;
  if (als->kind=="AND"){
      // AND
    cout <<als->down->text <<"AND"<<als->down->right->text<<endl;
  }
  else if (als->kind=="MINUS"){
      // MINUS
    cout <<als->down->text <<"MINUS"<<als->down->right->text<<endl;
  }
  else if (als->kind=="*"){
      // *
    cout <<als->down->text <<"*"<<als->down->right->text<<endl;
  }

  
  // operacion
  // AND unio
  // MINUS resta
  // * multiplica la resta
  /*if (als->down->right->kind == "AND") {
    cout << "AND" << endl;
  }
  else if (als->down->right->kind == "MINUS") {
    cout << "MINUS" << endl;
  }
  else if (als->down->right->kind == "*") {
    cout << "*" << endl;
  }
  else{
    cout << "error: 2else" <<endl;
  }*/
}

void displayResults(AST *als){
  if (als->kind == "UNITATS"){
    lista_compra::iterator it;
    lista_compra aux;
    aux = m[als->down->text];
    int total_units = 0;

    for(it = aux.begin(); it != aux.end(); it++) total_units += it->second;
    cout << total_units << endl;
  }
  else if (als->kind == "PRODUCTES"){
    lista_compra aux;
    aux = m[als->down->text];
    lista_compra::iterator it = aux.begin();
    while(it != aux.end()){
      cout << it->first << ": " << it->second << endl;
      it++;
    }
  }
  else if (als->kind == "DESVIACIO"){
    // TODO:
    cout << "DESVIACIO" << endl;
  }
  else ;
}

void lookForPatterns(AST *als){
  if (als==NULL) return;
  else if (als->kind == "="){
    cout << "als->down->right->kind: " << als->down->right->kind << endl;
    // list type
    if (als->down->right->kind == "[") {
      AST *aux;
      // Aux points to the first list item.
      aux = als->down->right->down;
      // Assigns to the id the list aux.
      assignation(als->down->text, aux);
    }
    else {
      AST *aux;
      aux = als->down->right;
      operation(als->down->text, aux);
    }
    // m[als->text][""] = 0;
  }
  else{
    displayResults(als);
  }
  lookForPatterns(als->right);
}

//////////////////////////////////////////////////////////////////////////////
// MAIN
//////////////////////////////////////////////////////////////////////////////
int main() {
  root = NULL;
  ANTLR(compres(&root), stdin);
  ASTPrint(root);
  // execute(root->down);
  lookForPatterns(root->down);
}
>>

#lexclass START
#token NUM "[0-9]+"
#token AND "AND"
#token MINUS "MINUS"
#token UNITS "UNITATS"
#token DESV "DESVIACIO"
#token PROD "PRODUCTES"
#token WRITE "write"
#token ID "[a-zA-Z][a-zA-Z0-9]*"

#token SPACE "[\ \n]" << zzskip();>>
#token ASIG "="
#token ADD "\+"
#token SUB "\-"
#token MUL "\*"
#token DIV "\/"
#token OCL "\["
#token CCL "\]"
#token OPAR "\("
#token CPAR "\)"
#token COMMA ","

compres: (list)* <<#0=createASTlist(_sibling);>> ;

// Id = expr | UNITATS, DESVIACIO, PRODUCTE
list: ID ASIG^ expr | UNITS^ ID | DESV^ ID | PROD^ ID;

// Id = [()] | Id = id (AND|MINUS|MUL) id
expr: def | oper;

oper: term ((AND^|MINUS^) term)* ;

// [(1,item),(2,items)]
def: OCL^ list_item (COMMA! list_item)* CCL!;

// (3,ID)
list_item: OPAR! NUM^ COMMA! ID CPAR!;

// 3*(id MINUS id) | 3 * id AND id
term: (NUM MUL^)* (ID | (OPAR! oper CPAR!));

// expr:  term ((PLUS^|MINUS^) term)* ;
// term: NUM ((TIMES^|DIV^) NUM)*;
