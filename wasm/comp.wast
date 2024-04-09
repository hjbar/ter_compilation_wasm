(module

  (func $print_i32 (import "spectest" "print_i32") (param i32))

  (func $main

    ;;
    i32.const 5
    i32.const 5
    i32.add

    i32.const 12
    i32.const 1
    i32.sub

    i32.le_u
    ;;

    ;;
    i32.const 1
    i32.const 2
    i32.div_u

    i32.const 2
    i32.const -3
    i32.add

    i32.lt_s
    ;;

    ;;
    i32.and
    ;;

    call $print_i32
  )

  (start $main)

)
