type typ = Ti32

type op =
  | Add
  | Sub
  | Mul
  | Div_s
  | Rem_s
  | Eq
  | Ne
  | Or
  | And
  | Lt_s
  | Le_s
  | Gt_s
  | Ge_s

type instr =
  | I32 of int32
  | Op of op
  | Get of mem_access
  | FunCall of string
  | If of typ option * seq option * seq option
  | Loop of string * seq option
  | Block of string * seq option
  | Jump of string
  | Set of mem_access
  | Return
  | Drop

and mem_access =
  | VarLocal of string
  | VarGlobal of string

and seq =
  | I of instr
  | S of seq * seq

let ( @@ ) s1 s2 = S (s1, s2)

type fun_def =
  { name : string
  ; params : (typ * string) list
  ; return : typ option
  ; locals : (typ * string) list
  ; code : seq option
  }

type wasm_module =
  { globals : (typ * string * instr) list
  ; functions : fun_def list
  ; start : string
  }

type program = wasm_module list
