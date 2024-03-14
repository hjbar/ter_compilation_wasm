open Format
open Wasm

let print_program fmt prog =
  let rec print_modules modules =
    let print_module m =
      fprintf fmt "(module ";

      copy_file "utils/head.wat";

      print_globals m.globals;

      copy_file "utils/array.wat";

      print_functions m.functions;

      fprintf fmt "(start $@SET_UP) ) "
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
    | FunCall s -> fprintf fmt "call $%s " s
    | Print -> fprintf fmt "call $@print_i32 "
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
    | Set (VarLocal name) -> fprintf fmt "local.set $%s " name
    | Set (VarGlobal name) -> fprintf fmt "global.set $%s " name
    | Return -> fprintf fmt "return "
    | Drop -> fprintf fmt "drop "
    | Array len ->
      print_seq (Some len);
      fprintf fmt "call $@arr "
    | Len (VarLocal s) ->
      fprintf fmt "local.get $%s " s;
      fprintf fmt "call $@len "
    | Len (VarGlobal s) ->
      fprintf fmt "global.get $%s " s;
      fprintf fmt "call $@len "
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
  and copy_file file =
    let in_c = open_in file in
    let rec loop () =
      match In_channel.input_line in_c with
      | None -> ()
      | Some str ->
        fprintf fmt "%s" str;
        loop ()
    in
    loop ();
    close_in in_c
  in

  print_modules prog
