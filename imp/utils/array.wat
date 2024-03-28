(func $@ARR (param $len i32) (result i32)
    (local $offset i32)

    (local.set $offset (i32.load (i32.const 0)))

    (i32.store (local.get $offset)
               (local.get $len)
    )

    (i32.store (i32.const 0)
               (i32.add
                   (i32.add
                       (local.get $offset)
                       (i32.mul
                           (local.get $len)
                           (i32.const 4)
                       )
                   )
                   (i32.const 4)
               )
    )

    (local.get $offset)
)

(func $@LEN (param $arr i32) (result i32)
    (i32.load (local.get $arr))
)

(func $@OFFSET (param $arr i32) (param $i i32) (result i32)
    (i32.add
         (i32.add (local.get $arr) (i32.const 4))
         (i32.mul (i32.const 4) (local.get $i))
    )
)

(func $@SET (param $arr i32) (param $i i32) (param $value i32)
    (i32.store
        (call $@OFFSET (local.get $arr) (local.get $i))
        (local.get $value)
    )
)

(func $@SET_RETURN (param $arr i32) (param $i i32) (param $value i32) (result i32)
    (call $@SET (local.get $arr) (local.get $i) (local.get $value))
    (local.get $arr)
)

(func $@SET_ALL (param $arr i32) (param $n i32) (result i32)
    (local $i i32) (local $len i32)

    (local.set $i (i32.const 0))
    (local.set $len (call $@LEN (local.get $arr)))

    (block $block
        (loop $loop
            (call $@SET (local.get $arr) (local.get $i) (call $@ARR (local.get $n)))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))

            (i32.lt_s (local.get $i) (local.get $len))
            (if
                (then
                    br $loop
                )
                (else
                    br $block
                )
            )
        )
    )

    local.get $arr
)

(func $@GET (param $arr i32) (param $i i32) (result i32)
    (i32.load
        (call $@OFFSET (local.get $arr) (local.get $i))
    )
)

(func $@SET_UP
    (i32.store (i32.const 0) (i32.const 4))
    (call $main)
)
