(module $math
    (func $add (export "add") (param $n1 i32) (param $n2 i32) (result i32)
        local.get $n1
        local.get $n2
        i32.add
    )
)

(module
    (func $print_i32 (import "spectest" "print_i32") (param i32))
    ;;(func $add (import "math" "add") (param i32) (param i32) (result i32))
    (func $main
        i32.const 1
        i32.const 2
        call $add
        call $print_i32
    )
    (start $main)
)
