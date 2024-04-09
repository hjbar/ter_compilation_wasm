(func $@ARR (param $len i32) (param $is_pointer i32) (result i32)
    (local $offset i32)
    (local $offset_vars i32)

    (i32.ge_s (i32.add (local.get $len) (i32.const 8)) (call $@FREE_CELLS))
    (if
      (then
        call $@STOP_AND_COPY

        (i32.ge_s (i32.add (local.get $len) (i32.const 8)) (call $@FREE_CELLS))
        (if
          (then
            unreachable
          )
        )

      )
    )

    (local.set $offset (global.get $@OFFSET_POINTER))

    (i32.store (global.get $@OFFSET_POINTER)
               (local.get $len)
    )

    (global.set $@OFFSET_POINTER (i32.add (global.get $@OFFSET_POINTER) (i32.const 4)))

    (i32.store (global.get $@OFFSET_POINTER) (local.get $is_pointer))

    (global.set $@OFFSET_POINTER
               (i32.add
                   (i32.add
                       (global.get $@OFFSET_POINTER)
                       (i32.mul
                           (local.get $len)
                           (i32.const 4)
                       )
                   )
                   (i32.const 4)
               )
    )

    (local.set $offset_vars (global.get $@ROOTS_POINTER))
    (i32.store (global.get $@ROOTS_POINTER) (local.get $offset))
    (global.set $@ROOTS_POINTER (i32.add (global.get $@ROOTS_POINTER) (i32.const 4)))

    local.get $offset_vars
)

(func $@LEN (param $arr i32) (result i32)
    (local $off_arr i32)
    (local.set $off_arr (i32.load (local.get $arr)))

    (i32.load (local.get $off_arr))
)

(func $@OFFSET (param $arr i32) (param $i i32) (result i32)
    (i32.add
         (i32.add (local.get $arr) (i32.const 8))
         (i32.mul (i32.const 4) (local.get $i))
    )
)

(func $@SET (param $arr i32) (param $i i32) (param $value i32)
    (local $off_arr i32)
    (local.set $off_arr (i32.load (local.get $arr)))

    (i32.store
        (call $@OFFSET (local.get $off_arr) (local.get $i))
        (local.get $value)
    )
)

(func $@SET_RETURN (param $arr i32) (param $i i32) (param $value i32) (result i32)
    (call $@SET (local.get $arr) (local.get $i) (local.get $value))
    (local.get $arr)
)

(func $@GET (param $arr i32) (param $i i32) (result i32)
    (local $off_arr i32)
    (local.set $off_arr (i32.load (local.get $arr)))

    (i32.load
        (call $@OFFSET (local.get $off_arr) (local.get $i))
    )
)
