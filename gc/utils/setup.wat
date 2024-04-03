(func $@SET_UP

    ;; Pointer next_free
    (i32.store (i32.const 0) (i32.const 4))

    ;; Pointer stack
    (i32.store (i32.const 65532) (i32.const 65532))

    (call $main)
)
