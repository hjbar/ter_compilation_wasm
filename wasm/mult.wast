;; Multiplication naïve a * b avec a >= 0

(module

  (func $print_i32 (import "spectest" "print_i32") (param i32))

  (func $mult (param $p0 i32) (param $p1 i32) (result i32)

    (local $n i32)
    (local $res i32)

    local.get $p0
    local.set $n
    i32.const 0
    local.set $res

    (loop $loop
      local.get $n
      (if
        (then
          local.get $n
          i32.const -1
          i32.add
          local.set $n

          local.get $p1
          local.get $res
          i32.add
          local.set $res

          br $loop
        )
      )
    )

    local.get $res
  )

  (func $main
    i32.const 4
    i32.const 5
    call $mult
    call $print_i32
  )

  (start $main)

)
