(module $array
 (func $print_i32 (import "spectest" "print_i32") (param i32))

    (memory (export "mem") 1)
    ;; create a array
    (func $arr (export "arr") (param $len i32) (result i32)
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
    (func $len (export "len") (param $arr i32) (result i32)
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
    (func $set (export "set") (param $arr i32) (param $i i32) (param $value i32)
        (i32.store
            (call $offset (local.get $arr) (local.get $i))
            (local.get $value)
        )
    )
    ;; get a value at the index
    (func $get (export "get") (param $arr i32) (param $i i32) (result i32)
        (i32.load
            (call $offset (local.get $arr) (local.get $i))
        )
    )

    (func $set_up

        i32.const 0
        call $print_i32

        (i32.store (i32.const 0) (i32.const 4))

        i32.const 1
        call $print_i32
    )

    (start $set_up)
)

(register "array" $array)
