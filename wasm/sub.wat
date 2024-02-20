;; Test de la soustraction | l'ordre des args ==> l'ordre d'ajout dans la pile

(module

  (func $print_i32 (import "spectest" "print_i32") (param i32))

  (func $main
    i32.const 5
    i32.const 4
    i32.sub
    call $print_i32

    i32.const 4
    i32.const 5
    i32.sub
    call $print_i32
  )

  (start $main)

)
