(module
  (import "spectest" "print_i32" (func $@PRINT_I32  (param i32)))
  (memory 1)
  (global $t1 (mut i32) i32.const 0)
  (global $t2 (mut i32) i32.const 0)
  (global $t3 (mut i32) i32.const 0)
  (global $@T1 (mut i32) i32.const 0)
  (global $@T0 (mut i32) i32.const 0)
  (global $@I2 (mut i32) i32.const 0)
  (global $@I1 (mut i32) i32.const 0)
  (global $@I0 (mut i32) i32.const 0)
  (func $@ARR (param $len i32) (result i32) (local $offset i32)
    i32.const 0
    i32.load align=1
    local.set $offset
    local.get $offset
    local.get $len
    i32.store align=1
    i32.const 0
    local.get $offset
    local.get $len
    i32.const 4
    i32.mul
    i32.add
    i32.const 4
    i32.add
    i32.store align=1
    local.get $offset
  )
  (func $@LEN (param $arr i32) (result i32)
    local.get $arr
    i32.load align=1
  )
  (func $@OFFSET (param $arr i32) (param $i i32) (result i32)
    local.get $arr
    i32.const 4
    i32.add
    i32.const 4
    local.get $i
    i32.mul
    i32.add
  )
  (func $@SET (param $arr i32) (param $i i32) (param $value i32)
    local.get $arr
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
  (func $@GET (param $arr i32) (param $i i32) (result i32)
    local.get $arr
    local.get $i
    call $@OFFSET
    i32.load align=1
  )
  (func $@SET_UP
    i32.const 0
    i32.const 4
    i32.store align=1
    call $main
  )
  (func $main
    i32.const 2
    call $@ARR
    global.set $t1
    global.get $t1
    i32.const 0
    i32.const 0
    call $@SET
    global.get $t1
    i32.const 1
    i32.const 1
    call $@SET
    global.get $t1
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t1
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t1
    call $@LEN
    call $@PRINT_I32
    i32.const 0
    global.set $@I0
    i32.const 2
    call $@ARR
    global.set $@T0
    (block $block
      (loop $loop
        global.get $@I0
        i32.const 2
        i32.lt_s
        (if
          (then
            global.get $@T0
            global.get $@I0
            i32.const 2
            call $@ARR
            call $@SET
            global.get $@I0
            i32.const 1
            i32.add
            global.set $@I0
            br $loop
          )
          (else
            br $block
          )
        )))
    global.get $@T0
    global.set $t2
    global.get $t2
    i32.const 0
    call $@GET
    i32.const 0
    i32.const 0
    call $@SET
    global.get $t2
    i32.const 0
    call $@GET
    i32.const 1
    i32.const 1
    call $@SET
    global.get $t2
    i32.const 1
    call $@GET
    i32.const 0
    i32.const 0
    call $@SET
    global.get $t2
    i32.const 1
    call $@GET
    i32.const 1
    i32.const 1
    call $@SET
    global.get $t2
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t2
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t2
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t2
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t2
    call $@LEN
    call $@PRINT_I32
    global.get $t2
    i32.const 0
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t2
    i32.const 1
    call $@GET
    call $@LEN
    call $@PRINT_I32
    i32.const 0
    global.set $@I1
    i32.const 2
    call $@ARR
    global.set $@T1
    (block $block
      (loop $loop
        global.get $@I1
        i32.const 2
        i32.lt_s
        (if
          (then
            i32.const 0
            global.set $@I2
            global.get $@T1
            global.get $@I1
            i32.const 2
            call $@ARR
            call $@SET
            (block $block
              (loop $loop
                global.get $@I2
                i32.const 2
                i32.lt_s
                (if
                  (then
                    global.get $@T1
                    global.get $@I1
                    call $@GET
                    global.get $@I2
                    i32.const 2
                    call $@ARR
                    call $@SET
                    global.get $@I2
                    i32.const 1
                    i32.add
                    global.set $@I2
                    br $loop
                  )
                  (else
                    br $block
                  )
                )))
            global.get $@I1
            i32.const 1
            i32.add
            global.set $@I1
            br $loop
          )
          (else
            br $block
          )
        )))
    global.get $@T1
    global.set $t3
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    i32.const 0
    i32.const 0
    call $@SET
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    i32.const 1
    i32.const 1
    call $@SET
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    i32.const 0
    i32.const 2
    call $@SET
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    i32.const 1
    i32.const 3
    call $@SET
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    i32.const 0
    i32.const 4
    call $@SET
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    i32.const 1
    i32.const 5
    call $@SET
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    i32.const 0
    i32.const 6
    call $@SET
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    i32.const 1
    i32.const 7
    call $@SET
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    call $@PRINT_I32
    global.get $t3
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 0
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 0
    call $@GET
    i32.const 1
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 0
    call $@GET
    call $@LEN
    call $@PRINT_I32
    global.get $t3
    i32.const 1
    call $@GET
    i32.const 1
    call $@GET
    call $@LEN
    call $@PRINT_I32
  )
  (start $@SET_UP)
)
