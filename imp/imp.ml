type typ =
  | TVoid
  | TInt
  | TBool
  | TArray of typ

let rec typ_to_string = function
  | TVoid -> "void"
  | TInt -> "int"
  | TBool -> "bool"
  | TArray t -> Printf.sprintf "%s array" (typ_to_string t)

type unop =
  | Opp
  | Not

type binop =
  | Add
  | Sub
  | Mul
  | Div
  | Rem
  | Lt
  | Le
  | Gt
  | Ge
  | Eq
  | Neq
  | And
  | Or

(* Expressions *)
type expr =
  (* Base arithmétique *)
  | Int of int
  | Bool of bool
  | Unop of unop * expr
  | Binop of binop * expr * expr
  (* Accès à une variable ou un attribut *)
  | Get of mem_access
  (* Appel de méthode *)
  | FunCall of string * expr list
  (* Tableau explicite *)
  | Array of expr list

(* Accès mémoire : variable ou attribut d'un objet *)
and mem_access =
  | Var of string
  | ArrField of expr * expr

(* Instructions *)
type instr =
  (* Affichage d'une expression *)
  | Print of expr
  (* Écriture dans une variable ou un attribut *)
  | Set of mem_access * expr
  (* Structures de contrôle usuelles *)
  | If of expr * seq * seq
  | While of expr * seq
  | Break
  | Continue
  (* Fin d'une fonction *)
  | Return of expr
  (* Expression utilisée comme instruction *)
  | Expr of expr

and seq = instr list

(*
  Définition de fonction
  Syntaxe : def <type de retour> <nom> (<params>) { ... }
*)
type fun_def =
  { return : typ
  ; fun_name : string
  ; params : (typ * string) list
  ; locals : (typ * string * expr option) list
  ; code : seq
  }

(*
  Programme complet :
  variables globales, classes, et une séquenced'instructions
*)
type program =
  { globals : (typ * string * expr option) list
  ; functions : fun_def list
  ; main : seq
  }
