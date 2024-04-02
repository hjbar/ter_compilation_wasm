(func $@WHICH_REGION (result i32)

    i32.const 4
    (i32.load (i32.const 0))
    i32.le_s

    (i32.load (i32.const 0))
    i32.const 21848
    i32.lt_s

    i32.and

    (if (result i32)
      (then
        i32.const 1
      )
      (else
        i32.const 0
      )
    )

)

(func $@REGION_START (result i32)

    call $@WHICH_REGION

    (if (result i32)
      (then
        i32.const 4
      )
      (else
        i32.const 21848
      )
    )

)

(func $@NEXT_REGION_START (result i32)

    call $@WHICH_REGION

    (if (result i32)
      (then
        i32.const 21848
      )
      (else
        i32.const 4
      )
    )

)

(func $@IN_ACTIVE_REGION (param $addr i32) (result i32) (local $addr_max i32)

    call $@WHICH_REGION

    (if
      (then
        (local.set $addr_max (i32.const 21848))
      )
      (else
        (local.set $addr_max (i32.const 43692))
      )
    )

    call $@REGION_START
    local.get $addr
    i32.le_s

    local.get $addr
    local.get $addr_max
    i32.lt_s

    i32.and

)

(func $@FREE_CELLS (result i32) (local $addr_max i32)

    call $@WHICH_REGION

    (if
      (then
        (local.set $addr_max (i32.const 21848))
      )
      (else
        (local.set $addr_max (i32.const 43692))
      )
    )

    local.get $addr_max
    (i32.load (i32.const 0))
    i32.sub

)

(func $@MOVE_BLOCK (param $src i32) (result i32)
    (local $pt i32)
    (local $size i32)
    (local $next_addr i32)
    (local $i i32)
    (local $i_max i32)

    (call $@IN_ACTIVE_REGION (local.get $src))

    (if (result i32)

      (then
        (local.set $pt (i32.load (i32.add (local.get $src) (i32.const 4))))
        (call $@IN_ACTIVE_REGION (local.get $pt))

        (if
          (then
            (return (local.get $pt))
          )
        )

        (local.set $size (i32.load (local.get $src)))
        (local.set $next_addr (i32.load (i32.const 0)))

        (local.set $i (i32.const 0))
        (local.set $i_max (i32.add (local.get $size) (i32.const 1)))

        (loop $loop
            (i32.lt_s (local.get $i) (local.get $i_max))

            (if
              (then
                (i32.add (local.get $next_addr) (i32.mul (local.get $i) (i32.const 4)))
                (i32.load (i32.add (local.get $src) (i32.mul (local.get $i) (i32.const 4))))
                i32.store

                (local.set $i (i32.add (local.get $i) (i32.const 1)))

                br $loop
              )
            )

        )

        (i32.store (i32.add (local.get $src) (i32.const 4)) (local.get $next_addr))

        (i32.const 0)
        (i32.add (i32.add (local.get $next_addr) (i32.mul (local.get $size) (i32.const 4))) (i32.const 1))
        i32.store

        local.get $next_addr
      )

      (else
        local.get $src
      )

    )

)

(func $@STOP_AND_COPY
    (local $scan i32)
    (local $scan_len i32)
    (local $scan_stack i32)
    (local $i i32)
    (local $i_max i32)
    (local $addr i32)
    (local $pt i32)

    (local.set $scan (call $@NEXT_REGION_START))

    (local.set $scan_stack (i32.const 65528))
    (loop $loop
        (i32.ge_s (local.get $scan_stack) (i32.load (i32.const 65532)))

        (if
          (then
            (local.set $addr (call $@MOVE_BLOCK (local.get $scan_stack)))
            (i32.store (local.get $scan_stack) (local.get $addr))

            (local.set $scan_stack (i32.sub (local.get $scan_stack) (i32.const 4)))
            br $loop
          )
        )
    )

    (loop $loop
        (i32.lt_s (local.get $scan) (i32.load (i32.const 0)))

        (if
          (then
            (local.set $scan_len (i32.load (local.get $scan)))

            (local.set $i (i32.const 1))
            (local.set $i_max (i32.add (local.get $scan_len) (i32.const 1)))

            (loop $intern_loop
                (i32.lt_s (local.get $i) (local.get $i_max))

                (if
                  (then
                    (local.set $addr (i32.add (local.get $scan) (i32.mul (local.get $i) (i32.const 4))))
                    (local.set $pt (i32.load (local.get $addr)))

                    (i32.store (local.get $addr) (call $@MOVE_BLOCK (local.get $pt)))

                    (local.set $i (i32.add (local.get $i) (i32.const 1)))
                    br $intern_loop
                  )
                )

            )

            (i32.add (i32.add (local.get $scan) (i32.mul (local.get $scan_len) (i32.const 4)) (i32.const 1)))
            local.set $scan

            br $loop
          )
        )

    )

)
