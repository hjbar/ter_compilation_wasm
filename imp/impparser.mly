%{

  open Lexing
  open Imp

  let clear_vars vars =
    List.fold_left (
      fun acc (typ, l) ->
        acc
        @
        List.map (
          fun (name, expr) ->
            (typ, name, expr)
        ) l
    ) [] vars

%}


(* LISTE LEXEMES *)
%token <int> INT
%token <bool> BOOL
%token <string> IDENT
%token TINT TBOOL TVOID

%token ASSIGN

%token DEF RETURN

%token PLUS STAR DIV REM MINUS U_MINUS
%token EQUAL N_EQUAL
%token LT LE GT GE
%token AND OR NOT

%token IF ELSE
%token WHILE BREAK CONTINUE

%token LPAR RPAR BEGIN END LBRA RBRA
%token SEMI COMMA
%token PRINT LEN
%token MAIN EOF


(* REGLES DE PRIORITES *)
%nonassoc LBRA

%right OR
%right AND
%nonassoc NOT

%left EQUAL N_EQUAL
%left LT LE GT GE

%left PLUS MINUS
%left STAR DIV REM
%nonassoc U_MINUS


(* POINT D'ENTREE *)
%start program
%type <Imp.program> program

%%


program:
 | globals_decl=declaration* functions=fun_def* MAIN BEGIN main=instruction* END EOF
  {
    let globals = clear_vars globals_decl in
    {globals ; functions ; main}
  }
;


declaration:
 | t=typ l=separated_nonempty_list(COMMA, decl) SEMI {  (t, l)  }
;


decl:
 | s=IDENT {  (s, None)  }
 | s=IDENT ASSIGN e=expression {  (s, Some e)  }
;


typ:
 | TVOID           { TVoid     }
 | TINT            { TInt      }
 | TBOOL           { TBool     }
 | t=typ LBRA RBRA { TArray(t) }
;


param:
 | t=typ s=IDENT {  (t, s)  }
;


fun_def:
 | DEF return=typ fun_name=IDENT LPAR params=separated_list(COMMA, param) RPAR BEGIN locals_decl=declaration* code=instruction* END
  {
    let locals = clear_vars locals_decl in
    {return ; fun_name ; params ; locals ; code}
  }
;


let mem ==
 | ~ = IDENT; <Var>
 | e1 = expression; LBRA; e2 = expression; RBRA; {  ArrField(e1, e2)  }


let instruction ==
 | PRINT; LPAR; ~ = expression; RPAR; SEMI; <Print>

 | IF; LPAR; e=expression; RPAR; BEGIN; s=instruction*; END; {  If(e, s, [])  }
 | IF; LPAR; ~ = expression; RPAR; BEGIN; ~ = instruction*; END; ELSE; BEGIN; ~ = instruction*; END; <If>

 | ~ = mem; ASSIGN; ~ = expression; SEMI; <Set>

 | WHILE; LPAR; ~ = expression; RPAR; BEGIN; ~ = instruction*; END; <While>
 | BREAK; SEMI; {  Break  }
 | CONTINUE; SEMI; {  Continue  }

 | RETURN; ~ = expression; SEMI; <Return>
 | ~ = expression; SEMI; <Expr>


let expression :=
 | ~ = INT; <Int>
 | ~ = BOOL; <Bool>
 | LBRA; ~ = separated_list(COMMA, expression); RBRA; <Array>

 | LPAR; e1=expression; RPAR; { e1 }
 | ~ = mem; <Get>

 | LEN; LPAR; ~ = expression; RPAR; <Len>

 | e1=expression; op=binop; e2=expression; {  Binop(op, e1, e2)  }
 | MINUS; e=expression; {  Unop(Opp, e)  } %prec U_MINUS
 | NOT;   e=expression; {  Unop(Not, e)  }

 | ~ = IDENT; LPAR; ~ = separated_list(COMMA, expression); RPAR; <FunCall>


%inline binop:
 | PLUS       { Add }
 | MINUS      { Sub }
 | STAR       { Mul }
 | DIV        { Div }
 | REM        { Rem }
 | LT         { Lt  }
 | LE         { Le  }
 | GT         { Gt  }
 | GE         { Ge  }
 | EQUAL      { Eq  }
 | N_EQUAL    { Neq }
 | AND        { And }
 | OR         { Or  }
;
