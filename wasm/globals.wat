(module

  (func $print_i32 (import "spectest" "print_i32") (param i32))

  (global $v0 (mut i32) (i32.const 0))

  (func $set_globals
    i32.const 5
    i32.const 5
    i32.add
    global.set $v0
  )

  (func $main
    call $set_globals
    global.get $v0
    call $print_i32
  )

  (start $main)

)
