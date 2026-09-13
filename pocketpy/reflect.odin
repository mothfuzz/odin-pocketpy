package pocketpy

import "core:reflect"
import "core:strings"
import "base:runtime"

ctx: runtime.Context

set_field :: proc(fv: any, pyval: Ref) -> bool {
    switch &value in fv {
    case i64:
        castint(pyval, &value) or_return
    case i32:
        v: i64
        castint(pyval, &v) or_return
        value = i32(v)
    case i16:
        v: i64
        castint(pyval, &v) or_return
        value = i16(v)
    case i8:
        v: i64
        castint(pyval, &v) or_return
        value = i8(v)
    case u64:
        v: i64
        castint(pyval, &v) or_return
        value = u64(v)
    case u32:
        v: i64
        castint(pyval, &v) or_return
        value = u32(v)
    case u16:
        v: i64
        castint(pyval, &v) or_return
        value = u16(v)
    case u8:
        v: i64
        castint(pyval, &v) or_return
        value = u8(v)
    case f32:
        castfloat32(pyval, &value) or_return
    case f64:
        castfloat(pyval, &value) or_return
    }
    return true
}
get_field :: proc(fv: any) -> bool {
    switch &value in fv {
    case i64:
        newint(retval(), value)
    case i32:
        newint(retval(), i64(value))
    case i16:
        newint(retval(), i64(value))
    case i8:
        newint(retval(), i64(value))
    case u64:
        newint(retval(), i64(value))
    case u32:
        newint(retval(), i64(value))
    case u16:
        newint(retval(), i64(value))
    case u8:
        newint(retval(), i64(value))
    case f64:
        newfloat(retval(), value)
    case f32:
        newfloat(retval(), f64(value))
    }
    return true
}

import "base:intrinsics"
bind_field :: proc(class: Type, $T: typeid, $slot: int) {
    field := reflect.struct_field_at(T, slot)
    field_name := strings.clone_to_cstring(field.name, context.temp_allocator)

    setter := proc "c" (argc: i32, argv: Ref) -> bool {
        context = ctx
        CHECK_ARGC(argc, 2) or_return
        self := (^T)(touserdata(arg(argv, 0)))
        field := reflect.struct_field_at(T, slot)
        //can't pass 'self' directly as any implicitly takes address-of
        base := any{rawptr(self), typeid_of(T)}
        fv := reflect.struct_field_value(base, field)
        set_field(fv, arg(argv, 1)) or_return
        newnone(retval())
        return true
    }

    getter := proc "c" (argc: i32, argv: Ref) -> bool {
        context = ctx
        CHECK_ARGC(argc, 1) or_return
        self := (^T)(touserdata(arg(argv, 0)))
        field := reflect.struct_field_at(T, slot)
        base := any{rawptr(self), typeid_of(T)}
        fv := reflect.struct_field_value(base, field)
        get_field(fv) or_return
        return true
    }
    bindproperty(class, field_name, getter, setter);
    when slot + 1 < intrinsics.type_struct_field_count(T) {
        bind_field(class, T, slot + 1)
    }
}

import "core:fmt"
bindstruct :: proc(module: GlobalRef, $T: typeid) {
    ctx = context

    info := type_info_of(T).variant.(reflect.Type_Info_Named)
    type_name := strings.clone_to_cstring(info.name, context.temp_allocator)

    class := newtype(type_name, builtin(.object), module, nil)

    __new__ := proc "c" (argc: i32, argv: Ref) -> bool {
        cls := totype(argv);
        newobject(retval(), cls, 0, size_of(T));
        return true
    }
    bindmethod(class, "__new__", __new__);


    __init__ := proc "c" (argc: i32, argv: Ref) -> bool {
        context = ctx
        n := i32(reflect.struct_field_count(T))
        CHECK_ARGC(argc, n+1) or_return
        self := (^T)(touserdata(arg(argv, 0)))
        base := any{rawptr(self), typeid_of(T)}
        for &field, i in reflect.struct_fields_zipped(T) {
            fv := reflect.struct_field_value(base, field)
            set_field(fv, arg(argv, i+1)) or_return
        }
        newnone(retval())
        return true
    }
    bindmethod(class, "__init__", __init__)

    __repr__ := proc "c" (argc: i32, argv: Ref) -> bool {
        CHECK_ARGC(argc, 1) or_return
        context = ctx
        strs := make([dynamic]string, context.temp_allocator)
        info := type_info_of(T).variant.(reflect.Type_Info_Named)
        self := (^T)(touserdata(arg(argv, 0)))
        base := any{rawptr(self), typeid_of(T)}
        append(&strs, fmt.tprintf("%s(", info.name))
        n := reflect.struct_field_count(T)
        for &field, i in reflect.struct_fields_zipped(T) {
            fv := reflect.struct_field_value(base, field)
            append(&strs, fmt.tprintf("%v", fv))
            if i < n - 1 {
                append(&strs, ", ")
            }
        }
        append(&strs, ")")
        cstr := strings.clone_to_cstring(strings.concatenate(strs[:], context.temp_allocator), context.temp_allocator)
        newstr(retval(), cstr)
        return true
    }
    bindmethod(class, "__repr__", __repr__)

    bind_field(class, T, 0)
}
