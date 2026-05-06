package main

import py "./pocketpy"
import "core:fmt"

Thing :: struct {
    i: i64,
    f: f32,
    d: f64,
}

Thing__new__ :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    cls := py.totype(argv)
    py.newobject(py.retval(), cls, 0, size_of(Thing))
    return true
}
Thing__init__ :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 4) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.castint(py.arg(argv, 1), &self.i) or_return
    py.castfloat32(py.arg(argv, 2), &self.f) or_return
    py.castfloat(py.arg(argv, 3), &self.d) or_return
    py.newnone(py.retval())
    return true
}
Thing_get_i :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 1) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.newint(py.retval(), self.i)
    return true
}
Thing_set_i :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 2) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.castint(py.arg(argv, 1), &self.i) or_return
    py.newnone(py.retval())
    return true
}
Thing_get_f :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 1) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.newfloat(py.retval(), f64(self.f))
    return true
}
Thing_set_f :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 2) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.castfloat32(py.arg(argv, 1), &self.f) or_return
    py.newnone(py.retval())
    return true
}
Thing_get_d :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 1) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.newfloat(py.retval(), self.d)
    return true
}
Thing_set_d :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 2) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    py.castfloat(py.arg(argv, 1), &self.d) or_return
    py.newnone(py.retval())
    return true
}
import "base:runtime"
Thing__repr__ :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 1) or_return
    self := (^Thing)(py.touserdata(py.arg(argv, 0)))
    context = runtime.default_context()
    str := fmt.ctprintf("Thing(%d, %.1f, %.1f)", self.i, self.f, self.d)
    py.newstr(py.retval(), str)
    return true
}

int_add :: proc "c" (argc: i32, argv: py.Ref) -> bool {
    py.CHECK_ARGC(argc, 2) or_return
    py.CHECK_ARG_TYPE(argv, 0, py.builtin(.int)) or_return
    py.CHECK_ARG_TYPE(argv, 1, py.builtin(.int)) or_return
    a: i64 = py.toint(py.arg(argv, 0))
    b: i64 = py.toint(py.arg(argv, 1))
    py.newint(py.retval(), a + b)
    return true
}

main :: proc() {
    py.initialize()
    defer py.finalize()

    //execute simple string
    py.exec("print('hello world!!!')", "<string>", .EXEC_MODE, nil)

    //bind global function
    r0 := py.getreg(0)
    py.newnativefunc(r0, int_add)
    py.setglobal(py.name("int_add"), r0)
    if !py.exec("print(int_add(1, 2))", "<string>", .EXEC_MODE, nil) {
        py.printexc()
    }

    //create module
    test_module := py.newmodule("test")

    //create class manually
    /*test_class := py.newtype("Thing", py.builtin(.object), test_module, nil)
    py.bindmethod(test_class, "__new__", Thing__new__);
    py.bindmethod(test_class, "__init__", Thing__init__);
    py.bindmethod(test_class, "__repr__", Thing__repr__);
    py.bindproperty(test_class, "i", Thing_get_i, Thing_set_i);
    py.bindproperty(test_class, "f", Thing_get_f, Thing_set_f);
    py.bindproperty(test_class, "d", Thing_get_d, Thing_set_d);*/

    //equivalent to bindstruct, which uses reflect
    py.bindstruct(test_module, Thing)

    script := #load("test.py", cstring)
    if !py.exec(script, "test.py", .EXEC_MODE, nil) {
        py.printexc()
    }
}
