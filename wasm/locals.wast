(module
  (func $print_i32 (import "spectest" "print_i32") (param i32))
    (func $main

    (local $var i32) ;; create a local variable named $var
    (local.set $var (i32.const 10)) ;; set $var to 10
    local.get $var ;; load $var onto the stack
    call $print_i32 ;; print the result

  )
  (start $main)
)
