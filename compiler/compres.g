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
// Stores a int value for a string "apples": 3
typedef map<string,int> shoppingList;
// Stores a list for a string "Compres1" = shoppingList
typedef map<string, shoppingList> idsList;
idsList m;
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

/* FUNCTION: assignation
 Stores list products and values identified by a given id
 - parameters:
    - id (string): the id of the variable.
    - als (pointer): it points to the first child of the instruction. */
void assignation(string id, AST *als){
  while (als != NULL){
    m[id][als->down->text] = atoi(als->text.c_str());
    als = als->right;
  }
}

/* FUNCTION: multOperation
 Multiplies the number of the products by a number and returns the calculated list.
 - parameters:
    - x (int): the number to be multiplied.
    - l (shoppingList): contains a list with items and units. */
shoppingList multOperation(int x, shoppingList & l){
  shoppingList aux;
  aux = l;
  shoppingList::iterator it;
  for (it = aux.begin(); it != aux.end(); ++it) it->second *= x;
  return aux;
}

/* FUNCTION: andOperation
 Returns c as the union of two lists a and b.
 - parameters:
    - a (shoppingList): a shopping list with items and units.
    - b (shoppingList): a shopping list with items and units.*/
shoppingList andOperation(shoppingList & a, shoppingList & b){
  shoppingList c; // 'c' the larger list and the list returned.
  shoppingList aux; // 'aux' the shortest list.

  c = b;
  aux = a;
  if (a.size() > b.size()) {
    c = a;
    aux = b;
  }

  shoppingList::iterator it;  // 'it' will iterate over the short list.
  shoppingList::iterator it2; // 'it2' will find if an item is inside c.

  // we iterate over the shortest list 'aux'.
  for(it=aux.begin(); it!=aux.end(); it++){
    it2 = c.find(it->first);
    if(it2 != c.end()) it2->second += it->second;
    else c[it->first] = it->second;
  }
  return c;
}

/* FUNCTION: minusOperation
 Returns c as the result of a - b
 - parameters:
    - a (shoppingList): a shopping list with items and units.
    - b (shoppingList): a shopping list with items and units. */
shoppingList minusOperation(shoppingList & a, shoppingList & b){
  shoppingList c; // 'c' the larger list.

  c = a;

  shoppingList::iterator it;  // 'it' will iterate over the second list. 
  shoppingList::iterator it2; // 'it2' will find if an item is inside 'a'.

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

/* FUNCTION: stdDesviation
 Returns the standard desviation of a list given by its id.
 - parameters:
    - id (string): identifies the name of a list.
  For further information about the standard desviation:
  http://en.wikipedia.org/wiki/Standard_deviation  */
double stdDesviation(string id){
  double mean = 0.0;
  double desviation = 0.0;
  shoppingList l;
  shoppingList::iterator it;
  l = m[id];

  // calculate the mean
  for(it=l.begin(); it!=l.end(); it++) mean += it->second;
  mean /= l.size();

  // calculate the std desviation
  for(it=l.begin(); it!=l.end(); it++) desviation += pow(it->second - mean,2);
  desviation = sqrt(desviation/l.size());

  return desviation;
}

/* FUNCTION: operation
 Calculates operations recursively between lists or between a number and a list and returns the result list.
 The operations can be:
  -'AND': to merge two lists.
  -'MINUS': to substract a list from another.
  -'*': to multiply the number of the products of a list.
 - parameters:
    - als (pointer): it points to the first child of the instruction. */
shoppingList operation(AST *als){
  if (als == NULL){
    shoppingList aux;
    return aux;
  }
  else{
      shoppingList aux1; // 1st child
      shoppingList aux2; // 2nd child

      aux1 = operation(als->down);
      // check if a 2nd child is factible and calls the function by it
      if (als->down != NULL and als->down->right != NULL) aux2 = operation(als->down->right);

      if (aux1.size() == 0 and aux2.size() == 0){
        // if returned empty lists

        if (als->kind == "id"){
          idsList::iterator it;
          it = m.find(als->text);
          if(it != m.end()) return it->second;
          else cerr << "**Compilation error: Variable '" <<als->text << "' is not declared." << endl;
        }
      }
      else if(aux1.size() == 0 and aux2.size() != 0){
        // if returned list by first child and filled list by second child

        // if the child is a id
        if (als->down->kind != "id"){
          int operand = atoi(als->down->text.c_str());
          // if the node is a multiplication
          if (als->kind == "*") return multOperation(operand, aux2);
          else cerr << "ERROR on: " << als->kind << endl;
        }
        else cerr <<"**Generation Error: (tree not genrated properly) brother " <<als->kind << als->text << " inconnected."<< endl;
      }
      else{
        if (als->kind == "AND") return andOperation (aux1, aux2);
        else if(als->kind == "MINUS") return minusOperation (aux1, aux2);
      }
      // Otherwise return empty list
      shoppingList aux;
      return aux;
  }
}

/* FUNCTION: displayResults
 This function displays info about the given parent nodes.
 - parameters:
    - als (pointer): it points to the first child of the instruction.
      Can be:
      - units of the list.
      - products followed by units of the list.
      - the standard desviation of the units of the list. */
void displayResults(AST *als){
  if (als->kind == "UNITATS"){
    // Display the list total # of items
    shoppingList aux;
    idsList::iterator it;
    it = m.find(als->down->text);
    int total_units = 0;

    // if the id has been declared
    if(it != m.end()){
      aux = m[als->down->text];
      shoppingList::iterator it;
      for(it = aux.begin(); it != aux.end(); it++) total_units += it->second;
    }
    // else show a neaty error message indicating the reason
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
    cout << "UNITATS " << als->down->text << ": " << total_units << endl;
  }
  else if (als->kind == "PRODUCTES"){
    // Display the items inside of the list
    shoppingList aux;
    idsList::iterator it;
    it = m.find(als->down->text);
    if(it!=m.end()){
      aux = m[als->down->text];
      shoppingList::iterator it = aux.begin();
      cout << "PRODUCTES " << als->down->text <<":"<< endl;
      while(it != aux.end()){
        cout << "    |--- " << it->first << ": " << it->second << endl;
        it++;
      }
    }
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
  }
  else if (als->kind == "DESVIACIO"){
    // Display the standard desviation of a list
    idsList::iterator it;
    it = m.find(als->down->text);
    if(it!=m.end())
      cout << "DESVIACIO " << als->down->text << ": " << stdDesviation(als->down->text) << endl;
    else cerr << "**ERROR: variable '" << als->down->text << "' not declared" << endl;
  }
  else ;
}

/* FUNCTION: lookForPatterns
 This function identifies patterns at first level, it can distinguish assignations from operations and from results display functions
 - parameters:
    - als (pointer): it points to the first child of the instruction. */
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
  lookForPatterns(root->down);
}
>>
//////////////////////////////////////////////////////////////////////////////
// TOKENS AND GRAMMAR DECLARATION
//////////////////////////////////////////////////////////////////////////////
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
