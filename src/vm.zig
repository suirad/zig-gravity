const std = @import("std");
const gravity = @import("gravity.zig");
const Delegate = gravity.Delegate;
const c = gravity.c;

pub const Vm = struct {
    inner: *c.gravity_vm,

    pub fn init(delegate: *Delegate) !Vm {
        const vm: ?*c.gravity_vm = c.gravity_vm_new(&delegate.inner);

        if (vm) |v| {
            return Vm{ .inner = v };
        }
        return error.FailedToInitVm;
    }

    pub fn deinit(self: *Vm) void {
        c.gravity_vm_free(self.inner);
        c.gravity_core_free();
        self.inner = undefined;
    }

    pub fn runmain(self: *Vm, closure: *c.gravity_closure_t) bool {
        return c.gravity_vm_runmain(self.inner, closure);
    }

    pub fn result(self: *Vm) c.gravity_value_t {
        return c.gravity_vm_result(self.inner);
    }

    pub fn valueDump(self: *Vm, val: c.gravity_value_t, buf: []u8) void {
        c.gravity_value_dump(self.inner, val, buf.ptr, @intCast(u16, buf.len));
    }
};
