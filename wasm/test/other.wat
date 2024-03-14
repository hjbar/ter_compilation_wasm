
(module
    (func $print_i32 (import "spectest" "print_i32") (param i32))
    (func $arr (import "array" "arr") (param i32) (result i32))
    (func $len (import "array" "len") (param i32) (result i32))
    (func $set (import "array" "set") (param i32) (param i32) (param i32))
    (func $get (import "array" "get") (param i32) (param i32) (result i32))
    (memory (import "array" "mem") 1)
    (func $main
        (local $a1 i32)

        i32.const 2
        call $print_i32

        ;; The first i32 records the beginning offset of available space
        ;; so the initial offset should be 4 (bytes)
        ;;(i32.store (i32.const 0) (i32.const 4))

        i32.const 5
        call $arr
        local.set $a1
           ;; create an array with length 0 and assign to $a1

           local.get $a1
       call $len
        call $print_i32
        ;; print length 5

        ;; set 10 at the index 1 in $a1
        local.get $a1
        i32.const 1
        i32.const 10
        call $set

        ;; get 10 at the index 1
        local.get $a1
        i32.const 1
        call $get
        call $print_i32
        ;; print the element value 10

        i32.const 3
        call $print_i32
    )
    (start $main)
)
