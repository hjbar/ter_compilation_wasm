open Imp
open Wasm

let int_wasm n = I32 n

let translate_type typ =
  match typ with TInt | TBool | TArray _ -> Some Ti32 | TVoid -> None

let translate_code vars_decl seq =
  match (vars_decl, seq) with
  | None, None -> None
  | (Some _ as seq), None | None, (Some _ as seq) -> seq
  | Some seq1, Some seq2 -> Some (seq1 @@ seq2)

let translate_seq f l local_env =
  let rec loop l s =
    match l with [] -> s | e :: ll -> loop ll (s @@ f e local_env)
  in
  match l with [] -> None | e :: ll -> Some (loop ll (f e local_env))

let translate_program (prog : Imp.program) =
  let rec translate_program_to_module (prog : Imp.program) :
    Wasm.wasm_module list =
    let vars_not_init, globals = translate_globals prog.globals in

    let main_fun = translate_main_to_function prog.main vars_not_init in
    let functions = main_fun :: translate_functions prog.functions in

    let start = "main" in

    [ { globals; functions; start } ]
  and translate_globals globals =
    let default_value expr_opt =
      match expr_opt with
      | Some (Int n) -> (true, int_wasm n)
      | None -> (true, int_wasm 0)
      | _ -> (false, int_wasm 0)
    in
    let seq = ref None in
    let vars =
      List.map
        (fun (typ, name, expr_opt) ->
          let type_wasm =
            match translate_type typ with
            | Some typ -> typ
            | None -> assert false
          in
          let is_init, default_value = default_value expr_opt in
          if not is_init then begin
            match (!seq, expr_opt) with
            | None, Some expr ->
              seq :=
                Some
                  ( translate_expr expr (Hashtbl.create 1)
                  @@ I (Set (VarGlobal name)) )
            | Some s, Some expr ->
              seq :=
                Some
                  ( s
                  @@ translate_expr expr (Hashtbl.create 1)
                  @@ I (Set (VarGlobal name)) )
            | _ -> assert false
          end;
          (type_wasm, name, default_value) )
        globals
    in
    (!seq, vars)
  and translate_main_to_function seq vars_not_init =
    let name = "main" in
    let params = [] in
    let return = None in
    let locals = [] in
    let code =
      translate_code vars_not_init (translate_instr_seq seq (Hashtbl.create 1))
    in
    { name; params; return; locals; code }
  and translate_functions fun_defs =
    let translate_locals locals env_local =
      let seq = ref None in
      let vars =
        List.map
          (fun (typ, name, expr_opt) ->
            let typ_wasm =
              match translate_type typ with
              | Some typ -> typ
              | None -> assert false
            in
            let default_value =
              match expr_opt with
              | None -> I (int_wasm 0)
              | Some expr -> translate_expr expr (Hashtbl.create 1)
            in
            let () =
              match !seq with
              | None -> seq := Some default_value
              | Some s ->
                seq := Some (s @@ default_value @@ I (Set (VarLocal name)))
            in
            Hashtbl.replace env_local name ();
            (typ_wasm, name) )
          locals
      in
      (!seq, vars)
    in
    let translate_fun (fun_def : Imp.fun_def) =
      let env_local = Hashtbl.create 16 in
      let name = fun_def.fun_name in
      let params =
        List.map
          (fun (typ, name) ->
            let typ_wasm =
              match translate_type typ with
              | Some typ -> typ
              | None -> assert false
            in
            Hashtbl.replace env_local name ();
            (typ_wasm, name) )
          fun_def.params
      in
      let return = translate_type fun_def.return in
      let vars_not_init, locals = translate_locals fun_def.locals env_local in
      let code =
        translate_code vars_not_init
          (translate_instr_seq fun_def.code env_local)
      in
      { name; params; return; locals; code }
    in
    List.map (fun fun_def -> translate_fun fun_def) fun_defs
  and translate_instr_seq l local_env =
    translate_seq translate_instr l local_env
  and translate_instr (instr : Imp.instr) local_env : Wasm.seq =
    let has_two_return seq1 seq2 =
      let rec has_return s =
        match s with
        | I instr -> instr = Return
        | S (s1, s2) -> has_return s1 || has_return s2
      in
      match (seq1, seq2) with
      | Some s1, Some s2 -> has_return s1 && has_return s2
      | _ -> false
    in
    let is_expr_void (expr : Imp.expr) =
      match expr with
      | FunCall (name, _) ->
        let f_def =
          List.find (fun f_def -> f_def.fun_name = name) prog.functions
        in
        f_def.return = TVoid
      | _ -> false
    in
    match instr with
    | Print expr -> translate_expr expr local_env @@ I Print
    | Set (Var name, expr) -> begin
      translate_expr expr local_env
      @@
      match Hashtbl.find_opt local_env name with
      | None -> I (Set (VarGlobal name))
      | Some _ -> I (Set (VarLocal name))
    end
    | Set (ArrField (s, i), v) -> translate_set_array s i v local_env
    | If (expr, s1, s2) ->
      let s1 = translate_instr_seq s1 local_env in
      let s2 = translate_instr_seq s2 local_env in
      let has_two_return = has_two_return s1 s2 in
      let return = if has_two_return then Some Ti32 else None in
      translate_expr expr local_env @@ I (If (return, s1, s2))
    | While (expr, s) ->
      let if_then =
        let jump = I (Jump "loop") in
        match translate_instr_seq s local_env with
        | None -> Some jump
        | Some seq -> Some (seq @@ jump)
      in
      let if_else = Some (I (Jump "block")) in
      let if_wasm =
        translate_expr expr local_env @@ I (If (None, if_then, if_else))
      in
      let loop = I (Loop ("loop", Some if_wasm)) in
      I (Block ("block", Some loop))
    | Break -> I (Jump "block")
    | Continue -> I (Jump "loop")
    | Return expr -> translate_expr expr local_env @@ I Return
    | Expr expr ->
      if is_expr_void expr then translate_expr expr local_env
      else translate_expr expr local_env @@ I Drop
  and translate_set_array s i v local_env =
    let i' = translate_expr i local_env in
    let v' = translate_expr v local_env in
    match Hashtbl.find_opt local_env s with
    | None -> I (Get (VarGlobal s)) @@ i' @@ v' @@ I (FunCall "set")
    | Some _ -> I (Get (VarLocal s)) @@ i' @@ v' @@ I (FunCall "set")
  and translate_expr_seq l local_env = translate_seq translate_expr l local_env
  and translate_expr expr local_env =
    let translate_binop (binop : Imp.binop) =
      I
        (Op
           ( match binop with
           | Add -> Add
           | Sub -> Sub
           | Mul -> Mul
           | Div -> Div_s
           | Rem -> Rem_s
           | Lt -> Lt_s
           | Le -> Le_s
           | Gt -> Gt_s
           | Ge -> Ge_s
           | Eq -> Eq
           | Neq -> Ne
           | And -> And
           | Or -> Or ) )
    in
    match expr with
    | Int n -> I (int_wasm n)
    | Bool b -> I (int_wasm (if b then 1 else 0))
    | Unop (Opp, e) ->
      translate_expr e local_env @@ I (int_wasm (-1)) @@ I (Op Mul)
    | Unop (Not, e) ->
      let if_not =
        If (Some Ti32, Some (I (int_wasm 0)), Some (I (int_wasm 1)))
      in
      translate_expr e local_env @@ I if_not
    | Binop (b, e1, e2) ->
      translate_expr e1 local_env
      @@ translate_expr e2 local_env
      @@ translate_binop b
    | Get (Var name) -> begin
      match Hashtbl.find_opt local_env name with
      | None -> I (Get (VarGlobal name))
      | Some _ -> I (Get (VarLocal name))
    end
    | Get (ArrField (s, i)) -> begin
      let i' = translate_expr i local_env in
      match Hashtbl.find_opt local_env s with
      | None -> I (Get (VarGlobal s)) @@ i' @@ I (FunCall "get")
      | Some _ -> I (Get (VarLocal s)) @@ i' @@ I (FunCall "get")
    end
    | FunCall (name, expr_l) -> begin
      match translate_expr_seq expr_l local_env with
      | None -> I (FunCall name)
      | Some seq -> seq @@ I (FunCall name)
    end
    | Array l -> begin
      let len = I (int_wasm (List.length l)) in
      let init_array = I (Array len) in

      let idx = ref 0 in
      let init_elem =
        List.fold_left
          (fun acc e ->
            let e' = translate_set_array "$TMP" (Int !idx) e local_env in
            incr idx;
            match acc with None -> Some e' | Some seq -> Some (seq @@ e') )
          None l
      in

      match init_elem with
      | None -> init_array
      | Some seq ->
        init_array @@ I (Set (VarGlobal "$TMP")) @@ seq
        @@ I (Get (VarGlobal "$TMP"))
    end
  in
  translate_program_to_module prog
