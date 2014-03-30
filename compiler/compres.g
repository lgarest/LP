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
    attr->kind = "num";
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
}

void assignation(string id, AST *als){
  while (als != NULL){
    m[id][als->down->text] = atoi(als->text.c_str());
    als = als->right;
  }
}

lista_compra multOperation(int x, lista_compra & l){
  lista_compra aux;
  aux = l;
  lista_compra::iterator it;
  for (it = aux.begin(); it != aux.end(); ++it) it->second *= x;
  return aux;
}

lista_compra andOperation(lista_compra & a, lista_compra & b){
  lista_compra c; // c will be the larger list
  lista_compra aux; // aux will be the shortest list

  c = b;
  aux = a;
  if (a.size() > b.size()) {
    c = a;
    aux = b;
  }

  lista_compra::iterator it;
  lista_compra::iterator it2;

  // we iterate over the shortest list
  for(it=aux.begin(); it!=aux.end(); it++){
    it2 = c.find(it->first);
    if(it2 != c.end()) it2->second += it->second;
    else c[it->first] = it->second;
  }
  return c;
}

lista_compra minusOperation(lista_compra & a, lista_compra & b){
  lista_compra c; // c will be the larger list

  c = a;

  lista_compra::iterator it;
  lista_compra::iterator it2;

  // we iterate over the second list
  for(it=b.begin(); it!=b.end(); it++){
    it2 = c.find(it->first);
    if(it2 != c.end()) {
      it2->second -= it->second;
      if (it2->second < 0) it2->second = 0;
    }
  }
  return c;
}

double stdDesviation(string id){
  double mean = 0.0;
  double desviation = 0.0;
  lista_compra l;
  lista_compra::iterator it;
  l = m[id];

  // calculate the mean
  for(it=l.begin(); it!=l.end(); it++) mean += it->second;
  mean /= l.size();

  // calculate the std desviation
  for(it=l.begin(); it!=l.end(); it++) desviation += pow(it->second - mean,2);
  desviation = sqrt(desviation);

  return desviation;
}

lista_compra operation(AST *als){
  if (als == NULL){
    lista_compra aux;
    return aux;
  }
  else{
      lista_compra aux1; // 1st child
      lista_compra aux2; // 2nd child

      aux1 = operation(als->down);
      if (als->down != NULL and als->down->right != NULL) aux2 = operation(als->down->right);

      if (aux1.size() == 0 and aux2.size() == 0){
        // returned empty lists
        if (als->kind == "id"){
          lista_ids::iterator it;
          it = m.find(als->text);
          if(it != m.end()) return it->second;
          else cerr << "**Compilation error: Variable '" <<als->text << "' is not declared." << endl;
        }
      }
      // else if(aux1.size() != 0 and aux2.size() == 0){
      //   cout << als->kind << ":" << als->text << "|||| ";
      //   cout << als->down->kind << ":" << als->down->text << endl;
      // }
      else if(aux1.size() == 0 and aux2.size() != 0){
        if (als->down->kind != "id"){
          int operand = atoi(als->down->text.c_str());
          // cout << operand << " " << als->kind << " " << als->down->right->text << endl;
          if (als->kind == "*") return multOperation(operand, aux2);
          else cerr << "ERROR SHIT: " << als->kind << endl;
        }
        else cerr << als->kind << als->text <<" | **Generation Error: (tree not genrated properly) brother inconnected" << endl;
      }
      else{
        // cout << "Operation between: " << als->down->kind<<als->down->text << " " << als->kind <<" "<< als->down->right->text << als->down->right->kind << endl;
        if (als->kind == "AND") return andOperation (aux1, aux2);
        else if(als->kind == "MINUS") return minusOperation (aux1, aux2);
      }
      lista_compra aux;
      return aux;
  }
}

void displayResults(AST *als){
  if (als->kind == "UNITATS"){
    // Display the list total # of items
    lista_compra aux;
    lista_ids::iterator it;
    it = m.find(als->down->text);
    int total_units = 0;

    if(it != m.end()){
      aux = m[als->down->text];
      lista_compra::iterator it;
      for(it = aux.begin(); it != aux.end(); it++) total_units += it->second;
    }
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
    cout << total_units << endl;
  }
  else if (als->kind == "PRODUCTES"){
    // Display the items inside of the list
    lista_compra aux;
    lista_ids::iterator it;
    it = m.find(als->down->text);
    if(it!=m.end()){
      aux = m[als->down->text];
      lista_compra::iterator it = aux.begin();
      while(it != aux.end()){
        cout << it->first << ": " << it->second << endl;
        it++;
      }
    }
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
  }
  else if (als->kind == "DESVIACIO"){
    // Display the standard desviation of a list
    lista_ids::iterator it;
    it = m.find(als->down->text);
    if(it!=m.end())
      cout << "DESVIACIO: " << stdDesviation(als->down->text) << endl;
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
  }
  else ;
}

/* FUNCTION: lookForPatterns
 This function identifies patterns at first level, it can distinguish assignations from operations and from results display functions
 - parameters:
    - als (pointer): it points to the first child of the instruction.
*/
void lookForPatterns(AST *als){
  // base case: return NULL value
  if (als==NULL) return;
  else{
    // recursive case:
    // - 1: identify the pattern
    // - 2: get the result from the instruction
    // - 3: call recursively to the next instruction
    if (als->kind == "="){
      // list declaration
      if (als->down->right->kind == "[") {
        AST *aux;
        // Aux points to the first list item
        aux = als->down->right->down;
        // Assigns to the id the result list aux
        assignation(als->down->text, aux);
      }
      else {
        // list as a result of consecutive operations
        AST *aux;
        aux = als->down->right;
        // aux points to the first operation between lists
        m[als->down->text] = operation(aux);
      }
    }
    else{
      // displays results
      displayResults(als);
    }
    // recursive call for the next instruction
    lookForPatterns(als->right);
  }
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
