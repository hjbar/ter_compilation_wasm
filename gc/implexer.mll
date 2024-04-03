{

  open Lexing
  open Impparser

  exception Error of string

  let keyword_or_ident =
  let h = Hashtbl.create 17 in
  List.iter (fun (s, k) -> Hashtbl.add h s k)
    [
    "main",       MAIN;
    "print",      PRINT;
    "len",        LEN;
    "malloc",     MALLOC;

    "if",         IF;
    "else",       ELSE;
    "while",      WHILE;
    "break",      BREAK;
    "continue",   CONTINUE;

    "true",       BOOL true;
    "false",      BOOL false;

    "def",        DEF;
    "return",     RETURN;

    "int",        TINT;
    "bool",       TBOOL;
    "void",       TVOID;
    ] ;
  fun s ->
    match Hashtbl.find_opt h s with
    | Some res -> res
    | None -> IDENT(s)

}

let digit = ['0'-'9']
let number = ['-']? digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*

rule token = parse
  | ['\n']            { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+  { token lexbuf }

  | "//" [^ '\n']* "\n"  { new_line lexbuf; token lexbuf }
  | "/*"                 { comment lexbuf; token lexbuf }

  | number as n       { INT(int_of_string n) }
  | ident  as id      { keyword_or_ident id  }

  | "+"   { PLUS }
  | "-"   { MINUS }
  | "*"   { STAR }
  | "/"   { DIV }
  | "%"   { REM }
  | "=="  { EQUAL }
  | "!="  { N_EQUAL }
  | "<"   { LT }
  | "<="  { LE }
  | ">"   { GT }
  | ">="  { GE }
  | "!"   { NOT }
  | "&&"  { AND }
  | "||"  { OR  }

  | "="   { ASSIGN }
  | ","   { COMMA }


  | ";"   { SEMI }
  | "("   { LPAR }
  | ")"   { RPAR }
  | "{"   { BEGIN }
  | "}"   { END }
  | "["   { LBRA }
  | "]"   { RBRA }

  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
