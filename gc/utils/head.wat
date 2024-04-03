(import "spectest" "print_i32" (func $@PRINT_I32  (param i32)))

(memory 4)

(global $@MEM1_START i32 (i32.const 0))
(global $@MEM2_START i32 (i32.const 65536))
(global $@ROOTS_START i32 (i32.const 131072))
(global $@STACK_START i32 (i32.const 196608))

(global $@OFFSET_POINTER (mut i32) (i32.const 0))
(global $@ROOTS_POINTER (mut i32) (i32.const 131072))
(global $@STACK_POINTER (mut i32) (i32.const 196608))
