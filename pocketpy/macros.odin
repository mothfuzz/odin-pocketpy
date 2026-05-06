package pocketpy


builtin :: proc "c" (pt: PredefinedType) -> Type {
    return Type(pt)
}

arg :: proc "c" (argv: Ref, i: int) -> Ref {
    return &argv[i]
}

CHECK_ARGC :: proc "c" (argc: i32, n: i32) -> bool {
    if argc != n {
        return exception(builtin(.TypeError), "expected %d arguments, got %d", argc, n)
    }
    return true
}

CHECK_ARG_TYPE :: proc "c" (argv: Ref, i: int, type: Type) -> bool {
    //checktype already raises an exception, so we don't need to
    if !checktype(&argv[i], type) {
        return false
    }
    return true
}
