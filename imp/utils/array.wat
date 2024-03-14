(func $@arr (param $len i32) (result i32)
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

(func $@len (param $arr i32) (result i32)
    (i32.load (local.get $arr))
)

(func $@offset (param $arr i32) (param $i i32) (result i32)
    (i32.add
         (i32.add (local.get $arr) (i32.const 4))
         (i32.mul (i32.const 4) (local.get $i))
    )
)

(func $@set (param $arr i32) (param $i i32) (param $value i32)
    (i32.store
        (call $@offset (local.get $arr) (local.get $i))
        (local.get $value)
    )
)

(func $@get (param $arr i32) (param $i i32) (result i32)
    (i32.load
        (call $@offset (local.get $arr) (local.get $i))
    )
)

(func $@SET_UP
    (i32.store (i32.const 0) (i32.const 4))
    (call $main)
)
