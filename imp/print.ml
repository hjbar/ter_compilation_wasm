open Format
open Wasm

let print_array_func fmt =
  fprintf fmt
    {|
    ;; create a array
    (func $arr (param $len i32) (result i32)
        (local $offset i32)                              ;; offset
        (local.set $offset (i32.load (i32.const 0)))     ;; load offset from the first i32

        (i32.store (local.get $offset)                   ;; load the length
                   (local.get $len)
        )

        (i32.store (i32.const 0)                         ;; store offset of available space
                   (i32.add
                       (i32.add
                           (local.get $offset)
                           (i32.mul
                               (local.get $len)
                               (i32.const 4)
                           )
                       )
                       (i32.const 4)                     ;; the first i32 is the length
                   )
        )
        (local.get $offset)                              ;; (return) the beginning offset of the array.
    )
    ;; return the array length
    (func $len (param $arr i32) (result i32)
        (i32.load (local.get $arr))
    )
    ;; convert an element index to the offset of memory
    (func $offset (param $arr i32) (param $i i32) (result i32)
        (i32.add
             (i32.add (local.get $arr) (i32.const 4))    ;; The first i32 is the array length
             (i32.mul (i32.const 4) (local.get $i))      ;; one i32 is 4 bytes
        )
    )
    ;; set a value at the index
    (func $set (param $arr i32) (param $i i32) (param $value i32)
        (i32.store
            (call $offset (local.get $arr) (local.get $i))
            (local.get $value)
        )
    )
    ;; get a value at the index
    (func $get (param $arr i32) (param $i i32) (result i32)
        (i32.load
            (call $offset (local.get $arr) (local.get $i))
        )
    )

    (func $set_up
      (i32.store (i32.const 0) (i32.const 4))
      (call $main)
    ) |}

let print_import fmt =
  fprintf fmt
    {| (func $print_i32 (import "spectest" "print_i32") (param i32))
    (memory 1)
    (global $$TMP (mut i32) (i32.const 0)) |}

let print_program fmt prog =
  let rec print_modules modules =
    let print_module m =
      fprintf fmt "(module ";

      print_import fmt;

      print_globals m.globals;

      print_array_func fmt;

      print_functions m.functions;

      (* fprintf fmt "(start $%s) ) " m.start *)
      fprintf fmt "(start $set_up) ) "
    in
    List.iter (fun m -> print_module m) modules
  and print_globals globals =
    let print_global typ name instr =
      fprintf fmt "(global $%s (mut %s) (" name (typ_to_string typ);
      print_instr instr;
      fprintf fmt ") ) "
    in
    List.iter (fun (typ, name, instr) -> print_global typ name instr) globals
  and print_functions functions =
    let print_function f =
      fprintf fmt "(func $%s " f.name;

      List.iter
        (fun (typ, name) ->
          fprintf fmt "(param $%s %s) " name (typ_to_string typ) )
        f.params;

      let () =
        match f.return with
        | None -> ()
        | Some typ -> fprintf fmt "(result %s) " (typ_to_string typ)
      in

      List.iter
        (fun (typ, name) ->
          fprintf fmt "(local $%s %s) " name (typ_to_string typ) )
        f.locals;

      print_seq f.code;
      fprintf fmt ") "
    in
    List.iter (fun f -> print_function f) functions
  and typ_to_string = function Ti32 -> "i32"
  and print_seq seq =
    let rec loop seq =
      match seq with
      | I instr -> print_instr instr
      | S (s1, s2) ->
        loop s1;
        loop s2
    in
    match seq with None -> () | Some seq -> loop seq
  and print_instr = function
    | I32 n -> fprintf fmt "i32.const %d " n
    | Op op -> fprintf fmt (op_to_string op)
    | Get (VarLocal s) -> fprintf fmt "local.get $%s " s
    | Get (VarGlobal s) -> fprintf fmt "global.get $%s " s
    | Get (ArrayField (VarLocal name, seq)) ->
      fprintf fmt "local.get $%s " name;
      print_seq (Some seq);
      fprintf fmt "call $get "
    | Get (ArrayField (VarGlobal name, seq)) ->
      fprintf fmt "global.get $%s " name;
      print_seq (Some seq);
      fprintf fmt "call $get "
    | FunCall s -> fprintf fmt "call $%s " s
    | Print -> fprintf fmt "call $print_i32 "
    | If (typ_opt, s1_opt, s2_opt) ->
      let () =
        match typ_opt with
        | None -> fprintf fmt "(if "
        | Some typ -> fprintf fmt "(if (result %s) " (typ_to_string typ)
      in
      if Option.is_some s1_opt then begin
        fprintf fmt "(then ";
        print_seq s1_opt;
        fprintf fmt ") "
      end;
      if Option.is_some s2_opt then begin
        fprintf fmt "(else ";
        print_seq s2_opt;
        fprintf fmt ") "
      end;
      fprintf fmt ") "
    | Loop (name, seq) ->
      fprintf fmt "(loop $%s " name;
      print_seq seq;
      fprintf fmt ") "
    | Block (name, seq) ->
      fprintf fmt "(block $%s " name;
      print_seq seq;
      fprintf fmt ") "
    | Jump name -> fprintf fmt "br $%s " name
    | Set (VarLocal name, None) -> fprintf fmt "local.set $%s " name
    | Set (VarGlobal name, None) -> fprintf fmt "global.set $%s " name
    | Set (ArrayField (VarLocal name, idx), Some value) ->
      fprintf fmt "local.get $%s " name;
      print_seq (Some idx);
      print_seq (Some value);
      fprintf fmt "call $set "
    | Set (ArrayField (VarGlobal name, idx), Some value) ->
      fprintf fmt "global.get $%s " name;
      print_seq (Some idx);
      print_seq (Some value);
      fprintf fmt "call $set "
    | Return -> fprintf fmt "return "
    | Drop -> fprintf fmt "drop "
    | Array len ->
      print_seq (Some len);
      fprintf fmt "call $arr "
    | Len (VarLocal s) ->
      fprintf fmt "local.get $%s " s;
      fprintf fmt "call $len "
    | Len (VarGlobal s) ->
      fprintf fmt "global.get $%s " s;
      fprintf fmt "call $len "
    | _ -> failwith "todo"
  and op_to_string = function
    | Add -> "i32.add "
    | Sub -> "i32.sub "
    | Mul -> "i32.mul "
    | Div_s -> "i32.div_s "
    | Rem_s -> "i32.rem_s "
    | Eq -> "i32.eq "
    | Ne -> "i32.ne "
    | Or -> "i32.or "
    | And -> "i32.and "
    | Lt_s -> "i32.lt_s "
    | Le_s -> "i32.le_s "
    | Gt_s -> "i32.gt_s "
    | Ge_s -> "i32.ge_s "
  in

  print_modules prog
