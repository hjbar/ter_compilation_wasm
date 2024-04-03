(module
  (import "spectest" "print_i32" (func $@PRINT_I32  (param i32)))
  (memory 4)
  (global $@MEM1_START i32 i32.const 0)
  (global $@MEM2_START i32 i32.const 65536)
  (global $@ROOTS_START i32 i32.const 131072)
  (global $@STACK_START i32 i32.const 196608)
  (global $@OFFSET_POINTER (mut i32) i32.const 0)
  (global $@ROOTS_POINTER (mut i32) i32.const 131072)
  (global $@STACK_POINTER (mut i32) i32.const 196608)
  (global $t (mut i32) i32.const 0)
  (global $t2 (mut i32) i32.const 0)
  (func $@ARR (param $len i32) (param $is_pointer i32) (result i32) (local $offset i32) (local $offset_vars i32)
    local.get $len
    i32.const 8
    i32.add
    call $@FREE_CELLS
    i32.ge_s
    (if
      (then
        call $@STOP_AND_COPY
        local.get $len
        i32.const 8
        i32.add
        call $@FREE_CELLS
        i32.ge_s
        (if
          (then
            unreachable
          )
        )
      )
    )
    global.get $@OFFSET_POINTER
    local.set $offset
    global.get $@OFFSET_POINTER
    local.get $len
    i32.store align=1
    global.get $@OFFSET_POINTER
    i32.const 4
    i32.add
    global.set $@OFFSET_POINTER
    global.get $@OFFSET_POINTER
    local.get $is_pointer
    i32.store align=1
    global.get $@OFFSET_POINTER
    local.get $len
    i32.const 4
    i32.mul
    i32.add
    i32.const 4
    i32.add
    global.set $@OFFSET_POINTER
    global.get $@ROOTS_POINTER
    local.set $offset_vars
    global.get $@ROOTS_POINTER
    local.get $offset
    i32.store align=1
    global.get $@ROOTS_POINTER
    i32.const 4
    i32.add
    global.set $@ROOTS_POINTER
    local.get $offset_vars
  )
  (func $@LEN (param $arr i32) (result i32) (local $off_arr i32)
    local.get $arr
    i32.load align=1
    local.set $off_arr
    local.get $off_arr
    i32.load align=1
  )
  (func $@OFFSET (param $arr i32) (param $i i32) (result i32)
    local.get $arr
    i32.const 8
    i32.add
    i32.const 4
    local.get $i
    i32.mul
    i32.add
  )
  (func $@SET (param $arr i32) (param $i i32) (param $value i32) (local $off_arr i32)
    local.get $arr
    i32.load align=1
    local.set $off_arr
    local.get $off_arr
    local.get $i
    call $@OFFSET
    local.get $value
    i32.store align=1
  )
  (func $@SET_RETURN (param $arr i32) (param $i i32) (param $value i32) (result i32)
    local.get $arr
    local.get $i
    local.get $value
    call $@SET
    local.get $arr
  )
  (func $@GET (param $arr i32) (param $i i32) (result i32) (local $off_arr i32)
    local.get $arr
    i32.load align=1
    local.set $off_arr
    local.get $off_arr
    local.get $i
    call $@OFFSET
    i32.load align=1
  )
  (func $@IS_POINTER (param $addr i32) (result i32)
    local.get $addr
    i32.const 4
    i32.add
    i32.load align=1
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
        global.get $@MEM2_START
        local.set $addr_max
      )
      (else
        global.get $@ROOTS_START
        local.set $addr_max
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
        global.get $@MEM2_START
        local.set $addr_max
      )
      (else
        global.get $@ROOTS_START
        local.set $addr_max
      )
    )
    local.get $addr_max
    global.get $@OFFSET_POINTER
    i32.sub
  )
  (func $@MOVE_BLOCK (param $src i32) (result i32) (local $pt i32) (local $size i32) (local $next_addr i32) (local $i i32) (local $i_max i32)
    local.get $src
    call $@IN_ACTIVE_REGION
    (if (result i32)
      (then
        local.get $src
        i32.const 4
        i32.add
        i32.load align=1
        local.set $pt
        local.get $pt
        call $@IS_POINTER
        (if
          (then
            local.get $pt
            call $@IN_ACTIVE_REGION
            (if
              (then
                local.get $pt
                return
              )
            )
          )
        )
        local.get $src
        i32.load align=1
        local.set $size
        global.get $@OFFSET_POINTER
        local.set $next_addr
        i32.const 0
        local.set $i
        local.get $size
        i32.const 1
        i32.add
        local.set $i_max
        (loop $loop
          local.get $i
          local.get $i_max
          i32.lt_s
          (if
            (then
              local.get $next_addr
              local.get $i
              i32.const 4
              i32.mul
              i32.add
              local.get $src
              local.get $i
              i32.const 4
              i32.mul
              i32.add
              i32.load align=1
              i32.store align=1
              local.get $i
              i32.const 1
              i32.add
              local.set $i
              br $loop
            )
          ))
        local.get $src
        i32.const 8
        i32.add
        local.get $next_addr
        i32.store align=1
        local.get $next_addr
        local.get $size
        i32.const 4
        i32.mul
        i32.add
        i32.const 8
        i32.add
        global.set $@OFFSET_POINTER
        local.get $next_addr
      )
      (else
        local.get $src
      )
    )
  )
  (func $@STOP_AND_COPY (local $scan i32) (local $scan_len i32) (local $scan_stack i32) (local $i i32) (local $i_max i32) (local $addr i32) (local $pt i32)
    call $@NEXT_REGION_START
    local.set $scan
    call $@NEXT_REGION_START
    global.set $@OFFSET_POINTER
    global.get $@ROOTS_START
    local.set $scan_stack
    (loop $loop
      local.get $scan_stack
      global.get $@ROOTS_POINTER
      i32.lt_s
      (if
        (then
          local.get $scan_stack
          call $@MOVE_BLOCK
          local.set $addr
          local.get $scan_stack
          local.get $addr
          i32.store align=1
          local.get $scan_stack
          i32.const 4
          i32.sub
          local.set $scan_stack
          br $loop
        )
      ))
    (loop $loop
      local.get $scan
      global.get $@OFFSET_POINTER
      i32.lt_s
      (if
        (then
          local.get $scan
          i32.load align=1
          local.set $scan_len
          i32.const 1
          local.set $i
          local.get $scan_len
          i32.const 1
          i32.add
          local.set $i_max
          (loop $intern_loop
            local.get $i
            local.get $i_max
            i32.lt_s
            (if
              (then
                local.get $scan
                local.get $i
                i32.const 4
                i32.mul
                i32.add
                local.set $addr
                local.get $addr
                i32.load align=1
                local.set $pt
                local.get $pt
                call $@IS_POINTER
                (if
                  (then
                    local.get $addr
                    local.get $pt
                    call $@MOVE_BLOCK
                    i32.store align=1
                  )
                )
                local.get $i
                i32.const 1
                i32.add
                local.set $i
                br $intern_loop
              )
            ))
          local.get $scan
          local.get $scan_len
          i32.const 4
          i32.mul
          i32.const 8
          i32.add
          i32.add
          local.set $scan
          br $loop
        )
      ))
  )
  (func $main
    i32.const 16000
    i32.const 0
    call $@ARR
    global.set $t
    global.get $t
    i32.const 0
    i32.const 1
    call $@SET
    global.get $t
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t
    call $@LEN
    call $@PRINT_I32
    i32.const 1
    i32.const 0
    call $@ARR
    global.set $t
    global.get $t
    i32.const 0
    i32.const 2
    call $@SET
    global.get $t
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t
    call $@LEN
    call $@PRINT_I32
    i32.const 16000
    i32.const 0
    call $@ARR
    global.set $t2
    global.get $t2
    i32.const 0
    i32.const 3
    call $@SET
    global.get $t2
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t2
    call $@LEN
    call $@PRINT_I32
  )
  (func $@SET_UP
    call $main
  )
  (start $@SET_UP)
)
