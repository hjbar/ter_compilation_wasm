open Format
open Owi

let () =
  (* Récupération du fichier *)
  let file = Sys.argv.(1) in
  let c = open_in file in

  (* Lexing & Parsing *)
  let lb = Lexing.from_channel c in
  let prog = Impparser.program Implexer.token lb in
  close_in c;

  (* Traduction *)
  let asm = Imp2wasm.translate_program prog in

  (* Ecriture *)
  let output_file = Filename.chop_suffix file ".imp" ^ ".wat" in
  let out = open_out output_file in
  let outf = formatter_of_out_channel out in
  Print.print_program outf asm;
  pp_print_flush outf ();
  close_out out;

  (* Formatage *)
  let path = Fpath.v output_file in
  Owi.Cmd_fmt.cmd true [ path ];

  (* Fin *)
  exit 0
