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
map<string,int> m;
map<string,bool> block;
AST *root;


// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == ID) {
    attr->kind = "id";
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
if (id != n->down->text) {cout << "MISMATCH: " << id << " " << n->down->text << endl;}
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
void ASTPrintIndent(AST *a,string s)
{
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") cout<<"("<<a->text<<")";
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
void ASTPrint(AST *a)
{
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
  // cout << "evaluate " << a->text << endl;
  if (a == NULL) return 0;
  else if (a->kind == "intconst") return atoi(a->text.c_str());
  else if (a->kind == "+") return evaluate(child(a,0)) + evaluate(child(a,1));
  else if (a->kind == "-") return evaluate(child(a,0)) - evaluate(child(a,1));
  else if (a->kind == "*") return evaluate(child(a,0)) * evaluate(child(a,1));
  else if (a->kind == "/") return evaluate(child(a,0)) / evaluate(child(a,1));
  else if (a->kind == "id") cout << "SURPRISE MUTHAFACKA" ;
  return m[a->text];
}

//////////////////////////////////////////////////////////////////////////////
// EXECUTE
//////////////////////////////////////////////////////////////////////////////
void execute(AST *als) {
  // cout << "execute" << endl;
  if (als == NULL) return;
  else if (als->kind == ":=") m[child(als,0)->text] = evaluate(child(als,1));
  else cout << evaluate(child(als,0)) << endl;
  execute(als->right);
}


//////////////////////////////////////////////////////////////////////////////
// MAIN
//////////////////////////////////////////////////////////////////////////////
int main() {
  root = NULL;
  ANTLR(compres(&root), stdin);
  ASTPrint(root);
  execute(root);
}
>>

#lexclass START
#token NUM "[0-9]+"
#token ADD "\+"
#token SUB "\-"
#token MUL "\*"
#token DIV "\/"
#token SPACE "[\ \n]" << zzskip();>>
#token WRITE "write"
#token ID "[a-zA-Z][a-zA-Z0-9]*"
#token ASIG ":="

compres: (opers)* <<#0=createASTlist(_sibling);>> ;
opers: (ID ASIG^ expr ) | (WRITE^ ID) ;
expr:  term ((ADD^|SUB^) term)* ;
term: NUM ((MUL^|DIV^) NUM)*;


