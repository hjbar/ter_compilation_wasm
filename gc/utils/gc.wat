(func $@IS_POINTER (param $addr i32) (result i32)
  (i32.load (i32.add (local.get $addr) (i32.const 4)))
)

(func $@WHICH_REGION (result i32)

    global.get $@MEM1_START
    global.get $@OFFSET_POINTER
    i32.le_s

    global.get $@OFFSET_POINTER
    global.get $@MEM2_START
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
        global.get $@MEM1_START
      )
      (else
        global.get $@MEM2_START
      )
    )

)

(func $@NEXT_REGION_START (result i32)

    call $@WHICH_REGION

    (if (result i32)
      (then
        global.get $@MEM2_START
      )
      (else
        global.get $@MEM1_START
      )
    )

)

(func $@IN_ACTIVE_REGION (param $addr i32) (result i32) (local $addr_max i32)

    call $@WHICH_REGION

    (if
      (then
        (local.set $addr_max (global.get $@MEM2_START))
      )
      (else
        (local.set $addr_max (global.get $@ROOTS_START))
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
        (local.set $addr_max (global.get $@MEM2_START))
      )
      (else
        (local.set $addr_max (global.get $@ROOTS_START))
      )
    )

    local.get $addr_max
    global.get $@OFFSET_POINTER
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

        (call $@IS_POINTER (local.get $pt))
        (if
          (then

            (call $@IN_ACTIVE_REGION (local.get $pt))
            (if
              (then
                (return (local.get $pt))
              )
            )

          )
        )

        (local.set $size (i32.load (local.get $src)))
        (local.set $next_addr (global.get $@OFFSET_POINTER))

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

        (i32.store (i32.add (local.get $src) (i32.const 8)) (local.get $next_addr))

        (i32.add (i32.add (local.get $next_addr) (i32.mul (local.get $size) (i32.const 4))) (i32.const 8))
        global.set $@OFFSET_POINTER

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
    (global.set $@OFFSET_POINTER (call $@NEXT_REGION_START))

    (local.set $scan_stack (global.get $@ROOTS_START))
    (loop $loop
        (i32.lt_s (local.get $scan_stack) (global.get $@ROOTS_POINTER))

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
        (i32.lt_s (local.get $scan) (global.get $@OFFSET_POINTER))

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

                    (call $@IS_POINTER (local.get $pt))
                    (if
                      (then
                        (i32.store (local.get $addr) (call $@MOVE_BLOCK (local.get $pt)))
                      )
                    )

                    (local.set $i (i32.add (local.get $i) (i32.const 1)))
                    br $intern_loop
                  )
                )

            )

            (i32.add (i32.add (local.get $scan) (i32.mul (local.get $scan_len) (i32.const 4)) (i32.const 8)))
            local.set $scan

            br $loop
          )
        )

    )

)
