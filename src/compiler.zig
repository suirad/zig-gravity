const std = @import("std");
const gravity = @import("gravity.zig");
const Delegate = gravity.Delegate;
const Vm = gravity.Vm;
const c = gravity.c;

pub const Compiler = struct {
    inner: *c.gravity_compiler_t,

    pub fn init(delegate: *Delegate) !Compiler {
        const compiler: ?*c.gravity_compiler_t = c.gravity_compiler_create(&delegate.inner);

        if (compiler) |comp| {
            return Compiler{ .inner = comp };
        }
        return error.FailedToInitCompiler;
    }

    pub fn deinit(self: *Compiler) void {
        c.gravity_compiler_free(self.inner);
        self.inner = undefined;
    }

    pub fn run(self: *Compiler, src: [:0]const u8, fileid: u32, is_static: bool, add_debug: bool) !*c.gravity_closure_t {
        const closure: ?*c.gravity_closure_t = c.gravity_compiler_run(self.inner, src.ptr, src.len, fileid, is_static, add_debug);

        if (closure) |clos| {
            return clos;
        }
        return error.FailedToCompile;
    }

    pub fn transfer(self: *Compiler, vm: *Vm) void {
        c.gravity_compiler_transfer(self.inner, vm.inner);
    }
};
