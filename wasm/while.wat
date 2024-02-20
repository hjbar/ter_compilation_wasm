(module

  (func $print_i32 (import "spectest" "print_i32") (param i32))

  (func $f_test (result i32)

    (local $n i32)
    i32.const 5
    local.set $n

    (block $block
      (loop $loop
        local.get $n
        i32.const 1
        i32.sub
        local.set $n

        local.get $n
        i32.const 2
        i32.sub

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

    local.get $n

  )

  (func $main
    call $f_test
    call $print_i32
  )

  (start $main)

)
