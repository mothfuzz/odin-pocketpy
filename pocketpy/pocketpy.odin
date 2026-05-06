/*
 *  Copyright (c) 2026 blueloveTH
 *  Distributed Under The MIT License
 *  https://github.com/pocketpy/pocketpy
 */
package pocketpy

import "core:c"

foreign import lib {
    "pocketpy.lib",
    "system:ws2_32.lib",
}


// clang-format off
PK_VERSION             :: "2.1.8"
PK_VERSION_MAJOR            :: 2
PK_VERSION_MINOR            :: 1
PK_VERSION_PATCH            :: 8
PK_ENABLE_OS                :: 1
PK_ENABLE_THREADS           :: 1
PK_ENABLE_DETERMINISM       :: 0
PK_ENABLE_WATCHDOG          :: 0
PK_ENABLE_CUSTOM_SNAME      :: 0
PK_ENABLE_MIMALLOC          :: 0
PK_GC_MIN_THRESHOLD     :: 20000
PK_VM_STACK_SIZE        :: 16384
PK_MAX_CO_VARNAMES          :: 64

/*************** internal settings ***************/
// This is the maximum character length of a module path
PK_MAX_MODULE_PATH_LEN      :: 63

// Hash table load factor (smaller ones mean less collision but more memory)
// For class instance
PK_INST_ATTR_LOAD_FACTOR    :: 0.67

// For class itself
PK_TYPE_ATTR_LOAD_FACTOR    :: 0.5
SYS_PLATFORM             :: 0
SYS_PLATFORM_STRING      :: "win32"
PK_IS_DESKTOP_PLATFORM   :: 1

c11_vec2i :: struct #raw_union {
	using _: struct {
		x, y: i32,
	},

	data: [2]i32,
	_i64: i64,
}

c11_vec3i :: struct #raw_union {
	using _: struct {
		x, y, z: i32,
	},

	data: [3]i32,
}

c11_vec4i :: struct #raw_union {
	using _: struct {
		x, y, z, w: i32,
	},

	data: [4]i32,
}

c11_vec2 :: struct #raw_union {
	using _: struct {
		x, y: f32,
	},

	data: [2]f32,
}

c11_vec3 :: struct #raw_union {
	using _: struct {
		x, y, z: f32,
	},

	data: [3]f32,
}

c11_mat3x3 :: struct #raw_union {
	using _: struct {
		_11, _12, _13: f32,
		_21, _22, _23: f32,
		_31, _32, _33: f32,
	},

	m:    [3][3]f32,
	data: [9]f32,
}

c11_color32 :: struct #raw_union {
	using _: struct {
		r: u8,
		g: u8,
		b: u8,
		a: u8,
	},

	data: [4]u8,
	_u32: u32,
}

OpaqueName :: struct {}

/// A pointer that represents a python identifier. For fast name resolution.
Name :: ^OpaqueName

/// An integer that represents a python type. `0` is invalid.
Type :: i16

/// A generic destructor function.
Dtor :: proc "c" (rawptr)

/// A string view type. It is helpful for passing strings which are not null-terminated.
c11_sv :: struct {
	data: cstring,
	size: i32,
}

/// A generic reference to a python object.
Ref :: [^]TValue

/// A reference which has the same lifespan as the python object.
ObjectRef :: [^]TValue

/// A global reference which has the same lifespan as the VM.
GlobalRef :: [^]TValue

/// A specific location in the value stack of the VM.
StackRef :: [^]TValue

/// An item reference to a container object. It invalidates when the container is modified.
ItemRef :: [^]TValue

/// An output reference for returning a value. Only use this for function arguments.
OutRef :: [^]TValue
Frame  :: struct {}

// An enum for tracing events.
TraceEvent :: enum i32 {
	LINE = 0,
	PUSH = 1,
	POP  = 2,
}

TraceFunc :: proc "c" (frame: ^Frame, _: TraceEvent)

/// A struct contains the callbacks of the VM.
Callbacks :: struct {
	/// Used by `__import__` to load a source or compiled module.
	importfile: proc "c" (path: cstring, data_size: ^i32) -> cstring,

	/// Called before `importfile` to lazy-import a C module.
	lazyimport: proc "c" (cstring) -> GlobalRef,

	/// Used by `print` to output a string.
	print: proc "c" (cstring),

	/// Flush the output buffer of `print`.
	flush: proc "c" (),

	/// Used by `input` to get a character.
	getchr: proc "c" () -> i32,

	/// Used by `gc.collect()` to mark extra objects for garbage collection.
	gc_mark: proc "c" (f: proc "c" (val: Ref, ctx: rawptr), ctx: rawptr),

	/// Used by `PRINT_EXPR` bytecode.
	displayhook: proc "c" (val: Ref) -> bool,
}

/// A struct contains the application-level callbacks.
AppCallbacks :: struct {
	on_vm_ctor: proc "c" (index: i32),
	on_vm_dtor: proc "c" (index: i32),
}

/// Native function signature.
/// @param argc number of arguments.
/// @param argv array of arguments. Use `py_arg(i)` macro to get the i-th argument.
/// @return `true` if the function is successful or `false` if an exception is raised.
CFunction :: proc "c" (argc: i32, argv: StackRef) -> bool

/// Python compiler modes.
/// + `EXEC_MODE`: for statements.
/// + `EVAL_MODE`: for expressions.
/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
CompileMode :: enum i32 {
	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	EXEC_MODE   = 0,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	EVAL_MODE   = 1,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	SINGLE_MODE = 2,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	RELOAD_MODE = 3,
}

@(default_calling_convention="c", link_prefix="py_")
foreign lib {
	/// Initialize pocketpy and the default VM.
	initialize :: proc() ---

	/// Finalize pocketpy and free all VMs. This opearation is irreversible.
	/// After this call, you cannot use any function from this header anymore.
	finalize :: proc() ---

	/// Get the current VM index.
	currentvm :: proc() -> i32 ---

	/// Switch to a VM.
	/// @param index index of the VM ranging from 0 to 16 (exclusive). `0` is the default VM.
	switchvm :: proc(index: i32) ---

	/// Reset the current VM.
	resetvm :: proc() ---

	/// Reset All VMs.
	resetallvm :: proc() ---

	/// Get the current VM context. This is used for user-defined data.
	getvmctx :: proc() -> rawptr ---

	/// Set the current VM context. This is used for user-defined data.
	setvmctx :: proc(ctx: rawptr) ---

	/// Setup the callbacks for the current VM.
	callbacks :: proc() -> ^Callbacks ---

	/// Setup the application callbacks
	appcallbacks :: proc() -> ^AppCallbacks ---

	/// Set `sys.argv`. Used for storing command-line arguments.
	sys_setargv :: proc(argc: i32, argv: ^cstring) ---

	/// Set the trace function for the current VM.
	sys_settrace :: proc(func: TraceFunc, reset: bool) ---

	/// Invoke the garbage collector.
	gc_collect :: proc() -> i32 ---

	/// Wrapper for `PK_MALLOC(size)`.
	malloc :: proc(size: c.size_t) -> rawptr ---

	/// Wrapper for `PK_REALLOC(ptr, size)`.
	realloc :: proc(ptr: rawptr, size: c.size_t) -> rawptr ---

	/// Wrapper for `PK_FREE(ptr)`.
	free :: proc(ptr: rawptr) ---

	/// A shorthand for `True`.
	True :: proc() -> GlobalRef ---

	/// A shorthand for `False`.
	False :: proc() -> GlobalRef ---

	/// A shorthand for `None`.
	None :: proc() -> GlobalRef ---

	/// A shorthand for `nil`. `nil` is not a valid python object.
	NIL :: proc() -> GlobalRef ---

	/// Get the current source location of the frame.
	Frame_sourceloc :: proc(frame: ^Frame, lineno: ^i32) -> cstring ---

	/// Python equivalent to `globals()` with respect to the given frame.
	Frame_newglobals :: proc(frame: ^Frame, out: OutRef) ---

	/// Python equivalent to `locals()` with respect to the given frame.
	Frame_newlocals :: proc(frame: ^Frame, out: OutRef) ---

	/// Get the function object of the frame.
	/// Returns `NULL` if not available.
	Frame_function :: proc(frame: ^Frame) -> StackRef ---

	/// Compile a source string into a code object.
	/// Use python's `exec()` or `eval()` to execute it.
	compile :: proc(source: cstring, filename: cstring, mode: CompileMode, is_dynamic: bool) -> bool ---

	/// Compile a `.py` file into a `.pyc` file.
	compilefile :: proc(src_path: cstring, dst_path: cstring) -> bool ---

	/// Run a compiled code object.
	execo :: proc(data: rawptr, size: i32, filename: cstring, module: Ref) -> bool ---

	/// Run a source string.
	/// @param source source string.
	/// @param filename filename (for error messages).
	/// @param mode compile mode. Use `EXEC_MODE` for statements `EVAL_MODE` for expressions.
	/// @param module target module. Use NULL for the main module.
	/// @return `true` if the execution is successful or `false` if an exception is raised.
	exec :: proc(source: cstring, filename: cstring, mode: CompileMode, module: Ref) -> bool ---

	/// Evaluate a source string. Equivalent to `py_exec(source, "<string>", EVAL_MODE, module)`.
	eval :: proc(source: cstring, module: Ref) -> bool ---

	/// Run a source string with smart interpretation.
	/// Example:
	/// `py_newstr(py_r0(), "abc");`
	/// `py_newint(py_r1(), 123);`
	/// `py_smartexec("print(_0, _1)", NULL, py_r0(), py_r1());`
	/// `// "abc 123" will be printed`.
	smartexec :: proc(source: cstring, module: Ref, #c_vararg _: ..any) -> bool ---

	/// Evaluate a source string with smart interpretation.
	/// Example:
	/// `py_newstr(py_r0(), "abc");`
	/// `py_smarteval("len(_)", NULL, py_r0());`
	/// `int res = py_toint(py_retval());`
	/// `// res will be 3`.
	smarteval :: proc(source: cstring, module: Ref, #c_vararg _: ..any) -> bool ---

	/// Create an `int` object.
	newint :: proc(OutRef, i64) ---

	/// Create a trivial value object.
	newtrivial :: proc(out: OutRef, type: Type, data: rawptr, size: i32) ---

	/// Create a `float` object.
	newfloat :: proc(OutRef, f64) ---

	/// Create a `bool` object.
	newbool :: proc(OutRef, bool) ---

	/// Create a `str` object from a null-terminated string (utf-8).
	newstr :: proc(OutRef, cstring) ---

	/// Create a `str` object with `n` UNINITIALIZED bytes plus `'\0'`.
	newstrn :: proc(OutRef, i32) -> cstring ---

	/// Create a `str` object from a `c11_sv`.
	newstrv :: proc(OutRef, c11_sv) ---

	/// Create a formatted `str` object.
	newfstr :: proc(OutRef, cstring, #c_vararg ..any) ---

	/// Create a `bytes` object with `n` UNINITIALIZED bytes.
	newbytes :: proc(_: OutRef, n: i32) -> ^u8 ---

	/// Create a `None` object.
	newnone :: proc(OutRef) ---

	/// Create a `NotImplemented` object.
	newnotimplemented :: proc(OutRef) ---

	/// Create a `...` object.
	newellipsis :: proc(OutRef) ---

	/// Create a `nil` object. `nil` is an invalid representation of an object.
	/// Don't use it unless you know what you are doing.
	newnil :: proc(OutRef) ---

	/// Create a `nativefunc` object.
	newnativefunc :: proc(OutRef, CFunction) ---

	/// Create a `function` object.
	newfunction :: proc(out: OutRef, sig: cstring, f: CFunction, docstring: cstring, slots: i32) -> Name ---

	/// Create a `boundmethod` object.
	newboundmethod :: proc(out: OutRef, self: Ref, func: Ref) ---

	/// Create a new object.
	/// @param out output reference.
	/// @param type type of the object.
	/// @param slots number of slots. Use `-1` to create a `__dict__`.
	/// @param udsize size of your userdata.
	/// @return pointer to the userdata.
	newobject :: proc(out: OutRef, type: Type, slots: i32, udsize: i32) -> rawptr ---

	/// Convert a null-terminated string to a name.
	name :: proc(cstring) -> Name ---

	/// Convert a name to a null-terminated string.
	name2str :: proc(Name) -> cstring ---

	/// Convert a name to a python `str` object with cache.
	name2ref :: proc(Name) -> GlobalRef ---

	/// Convert a `c11_sv` to a name.
	namev :: proc(c11_sv) -> Name ---

	/// Convert a name to a `c11_sv`.
	name2sv :: proc(Name) -> c11_sv ---

	/// Bind a function to the object via "decl-based" style.
	/// @param obj the target object.
	/// @param sig signature of the function. e.g. `add(x, y)`.
	/// @param f function to bind.
	bind :: proc(obj: Ref, sig: cstring, f: CFunction) ---

	/// Bind a method to type via "argc-based" style.
	/// @param type the target type.
	/// @param name name of the method.
	/// @param f function to bind.
	bindmethod :: proc(type: Type, name: cstring, f: CFunction) ---

	/// Bind a static method to type via "argc-based" style.
	/// @param type the target type.
	/// @param name name of the method.
	/// @param f function to bind.
	bindstaticmethod :: proc(type: Type, name: cstring, f: CFunction) ---

	/// Bind a function to the object via "argc-based" style.
	/// @param obj the target object.
	/// @param name name of the function.
	/// @param f function to bind.
	bindfunc :: proc(obj: Ref, name: cstring, f: CFunction) ---

	/// Bind a property to type.
	/// @param type the target type.
	/// @param name name of the property.
	/// @param getter getter function.
	/// @param setter setter function. Use `NULL` if not needed.
	bindproperty :: proc(type: Type, name: cstring, getter: CFunction, setter: CFunction) ---

	/// Bind a magic method to type.
	bindmagic :: proc(type: Type, name: Name, f: CFunction) ---

	/// Convert an `int` object in python to `int64_t`.
	toint :: proc(Ref) -> i64 ---

	/// Get the address of the trivial value object (16 bytes).
	totrivial :: proc(Ref) -> rawptr ---

	/// Convert a `float` object in python to `double`.
	tofloat :: proc(Ref) -> f64 ---

	/// Cast a `int` or `float` object in python to `double`.
	/// If successful, return true and set the value to `out`.
	/// Otherwise, return false and raise `TypeError`.
	castfloat :: proc(_: Ref, out: ^f64) -> bool ---

	/// 32-bit version of `py_castfloat`.
	castfloat32 :: proc(_: Ref, out: ^f32) -> bool ---

	/// Cast a `int` object in python to `int64_t`.
	castint :: proc(_: Ref, out: ^i64) -> bool ---

	/// Convert a `bool` object in python to `bool`.
	tobool :: proc(Ref) -> bool ---

	/// Convert a `type` object in python to `py_Type`.
	totype :: proc(Ref) -> Type ---

	/// Convert a user-defined object to its userdata.
	touserdata :: proc(Ref) -> rawptr ---

	/// Convert a `str` object in python to null-terminated string.
	tostr :: proc(Ref) -> cstring ---

	/// Convert a `str` object in python to char array.
	tostrn :: proc(_: Ref, size: ^i32) -> cstring ---

	/// Convert a `str` object in python to `c11_sv`.
	tosv :: proc(Ref) -> c11_sv ---

	/// Convert a `bytes` object in python to char array.
	tobytes :: proc(_: Ref, size: ^i32) -> ^u8 ---

	/// Resize a `bytes` object. It can only be resized down.
	bytes_resize :: proc(_: Ref, size: i32) ---

	/// Create a new type.
	/// @param name name of the type.
	/// @param base base type.
	/// @param module module where the type is defined. Use `NULL` for built-in types.
	/// @param dtor destructor function. Use `NULL` if not needed.
	newtype :: proc(name: cstring, base: Type, module: GlobalRef, dtor: Dtor) -> Type ---

	/// Check if the object is exactly the given type.
	istype :: proc(Ref, Type) -> bool ---

	/// Get the type of the object.
	typeof :: proc(self: Ref) -> Type ---

	/// Check if the object is an instance of the given type.
	isinstance :: proc(obj: Ref, type: Type) -> bool ---

	/// Check if the derived type is a subclass of the base type.
	issubclass :: proc(derived: Type, base: Type) -> bool ---

	/// Get type by module and name. e.g. `py_gettype("time", py_name("struct_time"))`.
	/// Return `0` if not found.
	gettype :: proc(module: cstring, name: Name) -> Type ---

	/// Check if the object is an instance of the given type exactly.
	/// Raise `TypeError` if the check fails.
	checktype :: proc(self: Ref, type: Type) -> bool ---

	/// Check if the object is an instance of the given type or its subclass.
	/// Raise `TypeError` if the check fails.
	checkinstance :: proc(self: Ref, type: Type) -> bool ---

	/// Get the magic method from the given type only.
	/// Return `nil` if not found.
	tpgetmagic :: proc(type: Type, name: Name) -> GlobalRef ---

	/// Search the magic method from the given type to the base type.
	/// Return `NULL` if not found.
	tpfindmagic :: proc(_: Type, name: Name) -> GlobalRef ---

	/// Search the name from the given type to the base type.
	/// Return `NULL` if not found.
	tpfindname :: proc(_: Type, name: Name) -> ItemRef ---

	/// Get the base type of the given type.
	tpbase :: proc(type: Type) -> Type ---

	/// Get the type object of the given type.
	tpobject :: proc(type: Type) -> GlobalRef ---

	/// Get the type name.
	tpname :: proc(type: Type) -> cstring ---

	/// Disable the type for subclassing.
	tpsetfinal :: proc(type: Type) ---

	/// Set attribute hooks for the given type.
	tphookattributes :: proc(type: Type, getattribute: proc "c" (self: Ref, name: Name) -> bool, setattribute: proc "c" (self: Ref, name: Name, val: Ref) -> bool, delattribute: proc "c" (self: Ref, name: Name) -> bool, getunboundmethod: proc "c" (self: Ref, name: Name) -> bool) ---

	/// Get the current `Callable` object on the stack of the most recent vectorcall.
	/// Return `NULL` if not available.
	/// NOTE: This function should be placed at the beginning of your bindings or you will get wrong result.
	inspect_currentfunction :: proc() -> StackRef ---

	/// Get the current `module` object where the code is executed.
	/// Return `NULL` if not available.
	inspect_currentmodule :: proc() -> GlobalRef ---

	/// Get the current frame object.
	/// Return `NULL` if not available.
	inspect_currentframe :: proc() -> ^Frame ---

	/// Python equivalent to `globals()`.
	newglobals :: proc(OutRef) ---

	/// Python equivalent to `locals()`.
	newlocals :: proc(OutRef) ---

	/// Get the i-th register.
	/// All registers are located in a contiguous memory.
	getreg :: proc(i: i32) -> GlobalRef ---

	/// Set the i-th register.
	setreg :: proc(i: i32, val: Ref) ---

	/// Get the last return value.
	/// Please note that `py_retval()` cannot be used as input argument.
	retval :: proc() -> GlobalRef ---

	/// Get an item from the object's `__dict__`.
	/// Return `NULL` if not found.
	getdict :: proc(self: Ref, name: Name) -> ItemRef ---

	/// Set an item to the object's `__dict__`.
	setdict :: proc(self: Ref, name: Name, val: Ref) ---

	/// Delete an item from the object's `__dict__`.
	/// Return `true` if the deletion is successful.
	deldict :: proc(self: Ref, name: Name) -> bool ---

	/// Prepare an insertion to the object's `__dict__`.
	emplacedict :: proc(self: Ref, name: Name) -> ItemRef ---

	/// Apply a function to all items in the object's `__dict__`.
	/// Return `true` if the function is successful for all items.
	/// NOTE: Be careful if `f` modifies the object's `__dict__`.
	applydict :: proc(self: Ref, f: proc "c" (name: Name, val: Ref, ctx: rawptr) -> bool, ctx: rawptr) -> bool ---

	/// Clear the object's `__dict__`. This function is dangerous.
	cleardict :: proc(self: Ref) ---

	/// Get the i-th slot of the object.
	/// The object must have slots and `i` must be in valid range.
	getslot :: proc(self: Ref, i: i32) -> ObjectRef ---

	/// Set the i-th slot of the object.
	setslot :: proc(self: Ref, i: i32, val: Ref) ---

	/// Get variable in the `builtins` module.
	getbuiltin :: proc(name: Name) -> ItemRef ---

	/// Get variable in the `__main__` module.
	getglobal :: proc(name: Name) -> ItemRef ---

	/// Set variable in the `__main__` module.
	setglobal :: proc(name: Name, val: Ref) ---

	/// Get the i-th object from the top of the stack.
	/// `i` should be negative, e.g. (-1) means TOS.
	peek :: proc(i: i32) -> StackRef ---

	/// Push the object to the stack.
	push :: proc(src: Ref) ---

	/// Push a `nil` object to the stack.
	pushnil :: proc() ---

	/// Push a `None` object to the stack.
	pushnone :: proc() ---

	/// Push a `py_Name` to the stack. This is used for keyword arguments.
	pushname :: proc(name: Name) ---

	/// Pop an object from the stack.
	pop :: proc() ---

	/// Shrink the stack by n.
	shrink :: proc(n: i32) ---

	/// Get a temporary variable from the stack.
	pushtmp :: proc() -> StackRef ---

	/// Get the unbound method of the object.
	/// Assume the object is located at the top of the stack.
	/// If return true:  `[self] -> [unbound, self]`.
	/// If return false: `[self] -> [self]` (no change).
	pushmethod :: proc(name: Name) -> bool ---

	/// Evaluate an expression and push the result to the stack.
	/// This function is used for testing.
	pusheval :: proc(expr: cstring, module: GlobalRef) -> bool ---

	/// Call a callable object via pocketpy's calling convention.
	/// You need to prepare the stack using the following format:
	/// `callable, self/nil, arg1, arg2, ..., k1, v1, k2, v2, ...`.
	/// `argc` is the number of positional arguments excluding `self`.
	/// `kwargc` is the number of keyword arguments.
	/// The result will be set to `py_retval()`.
	/// The stack size will be reduced by `2 + argc + kwargc * 2`.
	vectorcall :: proc(argc: u16, kwargc: u16) -> bool ---

	/// Call a function.
	/// It prepares the stack and then performs a `vectorcall(argc, 0, false)`.
	/// The result will be set to `py_retval()`.
	/// The stack remains unchanged if successful.
	call :: proc(f: Ref, argc: i32, argv: Ref) -> bool ---

	/// Call a type to create a new instance.
	tpcall :: proc(type: Type, argc: i32, argv: Ref) -> bool ---

	/// Call a `py_CFunction` in a safe way.
	/// This function does extra checks to help you debug `py_CFunction`.
	callcfunc :: proc(f: CFunction, argc: i32, argv: Ref) -> bool ---

	/// Perform a binary operation.
	/// The result will be set to `py_retval()`.
	/// The stack remains unchanged after the operation.
	binaryop :: proc(lhs: Ref, rhs: Ref, op: Name, rop: Name) -> bool ---

	/// lhs + rhs
	binaryadd :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs - rhs
	binarysub :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs * rhs
	binarymul :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs / rhs
	binarytruediv :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs // rhs
	binaryfloordiv :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs % rhs
	binarymod :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs ** rhs
	binarypow :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs << rhs
	binarylshift :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs >> rhs
	binaryrshift :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs & rhs
	binaryand :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs | rhs
	binaryor :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs ^ rhs
	binaryxor :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs @ rhs
	binarymatmul :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs == rhs
	eq :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs != rhs
	ne :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs < rhs
	lt :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs <= rhs
	le :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs > rhs
	gt :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// lhs >= rhs
	ge :: proc(lhs: Ref, rhs: Ref) -> bool ---

	/// Python equivalent to `lhs is rhs`.
	isidentical :: proc(Ref, Ref) -> bool ---

	/// Python equivalent to `bool(val)`.
	/// 1: true, 0: false, -1: error
	cbool :: proc(val: Ref) -> i32 ---

	/// Compare two objects.
	/// 1: lhs == rhs, 0: lhs != rhs, -1: error
	equal :: proc(lhs: Ref, rhs: Ref) -> i32 ---

	/// Compare two objects.
	/// 1: lhs < rhs, 0: lhs >= rhs, -1: error
	less :: proc(lhs: Ref, rhs: Ref) -> i32 ---

	/// Python equivalent to `callable(val)`.
	callable :: proc(val: Ref) -> bool ---

	/// Get the hash value of the object.
	hash :: proc(_: Ref, out: ^i64) -> bool ---

	/// Get the iterator of the object.
	iter :: proc(Ref) -> bool ---

	/// Get the next element from the iterator.
	/// 1: success, 0: StopIteration, -1: error
	next :: proc(Ref) -> i32 ---

	/// Python equivalent to `str(val)`.
	str :: proc(val: Ref) -> bool ---

	/// Python equivalent to `repr(val)`.
	repr :: proc(val: Ref) -> bool ---

	/// Python equivalent to `len(val)`.
	len :: proc(val: Ref) -> bool ---

	/// Python equivalent to `getattr(self, name)`.
	getattr :: proc(self: Ref, name: Name) -> bool ---

	/// Python equivalent to `setattr(self, name, val)`.
	setattr :: proc(self: Ref, name: Name, val: Ref) -> bool ---

	/// Python equivalent to `delattr(self, name)`.
	delattr :: proc(self: Ref, name: Name) -> bool ---

	/// Python equivalent to `self[key]`.
	getitem :: proc(self: Ref, key: Ref) -> bool ---

	/// Python equivalent to `self[key] = val`.
	setitem :: proc(self: Ref, key: Ref, val: Ref) -> bool ---

	/// Python equivalent to `del self[key]`.
	delitem :: proc(self: Ref, key: Ref) -> bool ---

	/// Get a module by path.
	getmodule :: proc(path: cstring) -> GlobalRef ---

	/// Create a new module.
	newmodule :: proc(path: cstring) -> GlobalRef ---

	/// Reload an existing module.
	importlib_reload :: proc(module: Ref) -> bool ---

	/// Import a module.
	/// The result will be set to `py_retval()`.
	/// -1: error, 0: not found, 1: success
	do_import :: proc(path: cstring) -> i32 ---

	/// Check if there is an unhandled exception.
	checkexc :: proc() -> bool ---

	/// Check if the unhandled exception is an instance of the given type.
	/// If match, the exception will be stored in `py_retval()`.
	matchexc :: proc(type: Type) -> bool ---

	/// Clear the unhandled exception.
	/// @param p0 the unwinding point. Use `NULL` if not needed.
	clearexc :: proc(p0: StackRef) ---

	/// Print the unhandled exception.
	printexc :: proc() ---

	/// Format the unhandled exception and return a null-terminated string.
	/// The returned string should be freed by the caller.
	formatexc :: proc() -> cstring ---

	/// Raise an exception by type and message. Always return false.
	exception :: proc(type: Type, fmt: cstring, #c_vararg _: ..any) -> bool ---

	/// Raise an exception object. Always return false.
	raise                        :: proc(Ref) -> bool ---
	KeyError                     :: proc(key: Ref) -> bool ---
	StopIteration                :: proc() -> bool ---
	debugger_waitforattach       :: proc(hostname: cstring, port: u16) ---
	debugger_status              :: proc() -> i32 ---
	debugger_exceptionbreakpoint :: proc(exc: Ref) ---
	debugger_exit                :: proc(code: i32) ---

	/// Create a `tuple` with `n` UNINITIALIZED elements.
	/// You should initialize all elements before using it.
	newtuple      :: proc(_: OutRef, n: i32) -> ObjectRef ---
	tuple_data    :: proc(self: Ref) -> ObjectRef ---
	tuple_getitem :: proc(self: Ref, i: i32) -> ObjectRef ---
	tuple_setitem :: proc(self: Ref, i: i32, val: Ref) ---
	tuple_len     :: proc(self: Ref) -> i32 ---

	/// Create an empty `list`.
	newlist :: proc(OutRef) ---

	/// Create a `list` with `n` UNINITIALIZED elements.
	/// You should initialize all elements before using it.
	newlistn     :: proc(_: OutRef, n: i32) ---
	list_data    :: proc(self: Ref) -> ItemRef ---
	list_getitem :: proc(self: Ref, i: i32) -> ItemRef ---
	list_setitem :: proc(self: Ref, i: i32, val: Ref) ---
	list_delitem :: proc(self: Ref, i: i32) ---
	list_len     :: proc(self: Ref) -> i32 ---
	list_swap    :: proc(self: Ref, i: i32, j: i32) ---
	list_append  :: proc(self: Ref, val: Ref) ---
	list_emplace :: proc(self: Ref) -> ItemRef ---
	list_clear   :: proc(self: Ref) ---
	list_insert  :: proc(self: Ref, i: i32, val: Ref) ---

	/// Create an empty `dict`.
	newdict :: proc(OutRef) ---

	/// -1: error, 0: not found, 1: found
	dict_getitem :: proc(self: Ref, key: Ref) -> i32 ---

	/// true: success, false: error
	dict_setitem :: proc(self: Ref, key: Ref, val: Ref) -> bool ---

	/// -1: error, 0: not found, 1: found (and deleted)
	dict_delitem :: proc(self: Ref, key: Ref) -> i32 ---

	/// -1: error, 0: not found, 1: found
	dict_getitem_by_str :: proc(self: Ref, key: cstring) -> i32 ---

	/// -1: error, 0: not found, 1: found
	dict_getitem_by_int :: proc(self: Ref, key: i64) -> i32 ---

	/// true: success, false: error
	dict_setitem_by_str :: proc(self: Ref, key: cstring, val: Ref) -> bool ---

	/// true: success, false: error
	dict_setitem_by_int :: proc(self: Ref, key: i64, val: Ref) -> bool ---

	/// -1: error, 0: not found, 1: found (and deleted)
	dict_delitem_by_str :: proc(self: Ref, key: cstring) -> i32 ---

	/// -1: error, 0: not found, 1: found (and deleted)
	dict_delitem_by_int :: proc(self: Ref, key: i64) -> i32 ---

	/// true: success, false: error
	dict_apply :: proc(self: Ref, f: proc "c" (key: Ref, val: Ref, ctx: rawptr) -> bool, ctx: rawptr) -> bool ---

	/// noexcept
	dict_len :: proc(self: Ref) -> i32 ---

	/// Create an UNINITIALIZED `slice` object.
	/// You should use `py_setslot()` to set `start`, `stop`, and `step`.
	newslice :: proc(OutRef) -> ObjectRef ---

	/// Create a `slice` object from 3 integers.
	newsliceint :: proc(out: OutRef, start: i64, stop: i64, step: i64) ---

	/************* random module *************/
	newRandom      :: proc(out: OutRef) ---
	Random_seed    :: proc(self: Ref, seed: i64) ---
	Random_random  :: proc(self: Ref) -> f64 ---
	Random_uniform :: proc(self: Ref, a: f64, b: f64) -> f64 ---
	Random_randint :: proc(self: Ref, a: i64, b: i64) -> i64 ---

	/************* array2d module *************/
	newarray2d        :: proc(out: OutRef, width: i32, height: i32) ---
	array2d_getwidth  :: proc(self: Ref) -> i32 ---
	array2d_getheight :: proc(self: Ref) -> i32 ---
	array2d_getitem   :: proc(self: Ref, x: i32, y: i32) -> ObjectRef ---
	array2d_setitem   :: proc(self: Ref, x: i32, y: i32, val: Ref) ---

	/************* vmath module *************/
	newvec2    :: proc(out: OutRef, _: c11_vec2) ---
	newvec3    :: proc(out: OutRef, _: c11_vec3) ---
	newvec2i   :: proc(out: OutRef, _: c11_vec2i) ---
	newvec3i   :: proc(out: OutRef, _: c11_vec3i) ---
	newvec4i   :: proc(out: OutRef, _: c11_vec4i) ---
	newcolor32 :: proc(out: OutRef, _: c11_color32) ---
	newmat3x3  :: proc(out: OutRef) -> ^c11_mat3x3 ---
	tovec2     :: proc(self: Ref) -> c11_vec2 ---
	tovec3     :: proc(self: Ref) -> c11_vec3 ---
	tovec2i    :: proc(self: Ref) -> c11_vec2i ---
	tovec3i    :: proc(self: Ref) -> c11_vec3i ---
	tovec4i    :: proc(self: Ref) -> c11_vec4i ---
	tomat3x3   :: proc(self: Ref) -> ^c11_mat3x3 ---
	tocolor32  :: proc(self: Ref) -> c11_color32 ---

	/************* json module *************/
	/// Python equivalent to `json.dumps(val)`.
	json_dumps :: proc(val: Ref, indent: i32) -> bool ---

	/// Python equivalent to `json.loads(val)`.
	json_loads :: proc(source: cstring) -> bool ---

	/************* pickle module *************/
	/// Python equivalent to `pickle.dumps(val)`.
	pickle_dumps :: proc(val: Ref) -> bool ---

	/// Python equivalent to `pickle.loads(val)`.
	pickle_loads :: proc(data: ^u8, size: i32) -> bool ---

	/************* pkpy module *************/
	/// Begin the watchdog with `timeout` in milliseconds.
	/// `PK_ENABLE_WATCHDOG` must be defined to `1` to use this feature.
	/// You need to call `py_watchdog_end()` later.
	/// If `timeout` is reached, `TimeoutError` will be raised.
	watchdog_begin :: proc(timeout: i64) ---

	/// Reset the watchdog.
	watchdog_end    :: proc() ---
	profiler_begin  :: proc() ---
	profiler_end    :: proc() ---
	profiler_reset  :: proc() ---
	profiler_report :: proc() -> cstring ---

	/************* Others *************/
	time_ns           :: proc() -> i64 ---
	time_monotonic_ns :: proc() -> i64 ---

	/// An utility function to read a line from stdin for REPL.
	replinput :: proc(buf: cstring, max_size: i32) -> i32 ---
}

/// Python favored string formatting.
/// %d: int
/// %i: py_i64 (int64_t)
/// %f: py_f64 (double)
/// %s: const char*
/// %q: c11_sv
/// %v: c11_sv
/// %c: char
/// %p: void*
/// %t: py_Type
/// %n: py_Name
PredefinedType :: enum i32 {
	nil                   = 0,
	object                = 1,
	type                  = 2,  // py_Type
	int                   = 3,
	float                 = 4,
	bool                  = 5,
	str                   = 6,
	str_iterator          = 7,
	list                  = 8,  // c11_vector
	tuple                 = 9,  // N slots
	list_iterator         = 10, // 1 slot
	tuple_iterator        = 11, // 1 slot
	slice                 = 12, // 3 slots (start, stop, step)
	range                 = 13,
	range_iterator        = 14,
	module                = 15,
	function              = 16,
	nativefunc            = 17,
	boundmethod           = 18, // 2 slots (self, func)
	super                 = 19, // 1 slot + py_Type
	BaseException         = 20,
	Exception             = 21,
	bytes                 = 22,
	namedict              = 23,
	locals                = 24,
	code                  = 25,
	dict                  = 26,
	dict_iterator         = 27, // 1 slot
	property              = 28, // 2 slots (getter + setter)
	star_wrapper          = 29, // 1 slot + int level
	staticmethod          = 30, // 1 slot
	classmethod           = 31, // 1 slot
	NoneType              = 32,
	NotImplementedType    = 33,
	ellipsis              = 34,
	generator             = 35,

	/* builtin exceptions */
	SystemExit            = 36,
	KeyboardInterrupt     = 37,
	StopIteration         = 38,
	SyntaxError           = 39,
	RecursionError        = 40,
	OSError               = 41,
	NotImplementedError   = 42,
	TypeError             = 43,
	IndexError            = 44,
	ValueError            = 45,
	RuntimeError          = 46,
	TimeoutError          = 47,
	ZeroDivisionError     = 48,
	NameError             = 49,
	UnboundLocalError     = 50,
	AttributeError        = 51,
	ImportError           = 52,
	AssertionError        = 53,
	KeyError              = 54,

	/* stdc */
	stdc_Memory           = 55,
	stdc_Char             = 56,
	stdc_UChar            = 57,
	stdc_Short            = 58,
	stdc_UShort           = 59,
	stdc_Int              = 60,
	stdc_UInt             = 61,
	stdc_Long             = 62,
	stdc_ULong            = 63,
	stdc_LongLong         = 64,
	stdc_ULongLong        = 65,
	stdc_Float            = 66,
	stdc_Double           = 67,
	stdc_Pointer          = 68,
	stdc_Bool             = 69,

	/* vmath */
	vec2                  = 70,
	vec3                  = 71,
	vec2i                 = 72,
	vec3i                 = 73,
	vec4i                 = 74,
	mat3x3                = 75,
	color32               = 76,

	/* array2d */
	array2d_like          = 77,
	array2d_like_iterator = 78,
	array2d               = 79,
	array2d_view          = 80,
	chunked_array2d       = 81,
}

TValue :: struct {
	type:   Type,
	is_ptr: bool,
	extra:  i32,

	using _: struct #raw_union {
		_i64:   i64,
		_f64:   f64,
		_bool:  bool,
		_cfunc: CFunction,
		_obj:   rawptr,
		_ptr:   rawptr,
		_chars: [16]i8,
	},
}

