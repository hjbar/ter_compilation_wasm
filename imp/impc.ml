open Format
open Owi

(* Compile le fichier donné par le nom en argument *)
let compile_file file =
  let c = open_in file in

  (* Lexing & Parsing *)
  let lb = Lexing.from_channel c in
  let prog = Impparser.program Implexer.token lb in
  close_in c;

  (* Traduction *)
  let asm = Imp2wasm.translate_program prog in

  (* Ecriture *)
  let output_file = Filename.chop_suffix file ".imp" ^ ".wast" in
  let out = open_out output_file in
  let outf = formatter_of_out_channel out in
  Print.print_program outf asm;
  pp_print_flush outf ();
  close_out out;

  (* Formatage *)
  let path = Fpath.v output_file in
  ignore (Owi.Cmd_fmt.cmd true [ path ]);

  path

(* Execute the fichier donné par le chemin en argument *)
let exec_file path =
  (* Owi.Cmd_script.cmd profiling debug optimize [ path ] no_exhaustion *)
  ignore (Owi.Cmd_script.cmd false false false [ path ] false)

(* Compile le fichier donné par le nom en argument, puis l'execute *)
let compile_file_with_exec file =
  let path = compile_file file in
  exec_file path

(* Execute en mode debug the fichier donné par le chemin en argument *)
let exec_file_with_debug path =
  (* Owi.Cmd_script.cmd profiling debug optimize [ path ] no_exhaustion *)
  ignore (Owi.Cmd_script.cmd false true false [ path ] false)

(* Compile le fichier donné par le nom en argument, puis l'execute en mode debug *)
let compile_file_with_debug file =
  let path = compile_file file in
  exec_file_with_debug path

(* Gere les options + appel et initialise les fonctions ci-dessus *)
let () =
  let usage_msg = "\nHelp Message\n\n  compile the given file" in
  let speclist =
    [ ( "--run"
      , Arg.String compile_file_with_exec
      , "run the file after compiled it" )
    ; ( "--debug"
      , Arg.String compile_file_with_debug
      , "run the file in debug mode after compiled it" )
    ]
  in
  Arg.parse speclist (fun file -> ignore (compile_file file)) usage_msg

(* Leve une erreur si il n'a pas de fichier a compiler *)
let () =
  if Array.length Sys.argv < 2 then begin
    eprintf "usage: %s <file>@\n" Sys.argv.(0);
    exit 1
  end
