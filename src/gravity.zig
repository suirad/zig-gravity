const std = @import("std");
const testing = std.testing;

pub const c = @cImport({
    @cInclude("gravity_compiler.h");
    @cInclude("gravity_macros.h");
    @cInclude("gravity_core.h");
    @cInclude("gravity_vm.h");
    @cInclude("gravity_delegate.h");
});

pub const Delegate = @import("delegate.zig").Delegate;
pub const Compiler = @import("compiler.zig").Compiler;
pub const Vm = @import("vm.zig").Vm;

pub fn default_report_error(vm: ?*c.gravity_vm, err_type: c_uint, msg: [*c]const u8, desc: c.error_desc_t, xdata: ?*anyopaque) callconv(.C) void {
    _ = vm;
    _ = err_type;
    _ = msg;
    _ = desc;
    _ = xdata;
    if (msg) |m| {
        std.debug.print("error is: {s}", .{m});
    }
    std.os.exit(0);
}

const source_code =
    \\ func sum (a, b) {
    \\     return a + b
    \\ }
    \\ func mul (a, b) {
    \\     return a * b
    \\ }
    \\ func main () {
    \\     var a = 10
    \\     var b = 20
    \\     return "hi"
    \\ }
;

test "basic embed example" {
    // example found: https://marcobambini.github.io/gravity/#/embedding
    var delegate = c.gravity_delegate_t{
        .error_callback = default_report_error,
        .xdata = null,
        .report_null_errors = true,
        .disable_gccheck_1 = false,
        .log_callback = null,
        .log_clear = null,
        .unittest_callback = null,
        .parser_callback = null,
        .type_callback = null,
        .precode_callback = null,
        .loadfile_callback = null,
        .filename_callback = null,
        .optional_classes = null,
        .bridge_initinstance = null,
        .bridge_setvalue = null,
        .bridge_getvalue = null,
        .bridge_setundef = null,
        .bridge_getundef = null,
        .bridge_execute = null,
        .bridge_blacken = null,
        .bridge_string = null,
        .bridge_equals = null,
        .bridge_clone = null,
        .bridge_size = null,
        .bridge_free = null,
    };

    const compiler = c.gravity_compiler_create(&delegate);
    defer c.gravity_compiler_free(compiler);

    const closure = c.gravity_compiler_run(compiler, source_code, source_code.len, 0, true, true);

    const vm = c.gravity_vm_new(&delegate);
    defer c.gravity_vm_free(vm);
    defer c.gravity_core_free();

    c.gravity_compiler_transfer(compiler, vm);

    // execute main closure
    if (c.gravity_vm_runmain(vm, closure)) {
        // get returned value
        const res = c.gravity_vm_result(vm);

        var buf = [_]u8{0} ** 512;

        c.gravity_value_dump(vm, res, &buf, buf.len);
        std.debug.print("RESULT: {s}\n", .{buf});
    }
}

test "same example but using the wrappers" {
    var config = Delegate.init(.{ .error_callback = default_report_error });

    var compiler = try Compiler.init(&config);
    defer compiler.deinit();

    const closure = try compiler.run(source_code, 0, true, true);

    var vm = try Vm.init(&config);
    defer vm.deinit();

    compiler.transfer(&vm);

    if (vm.runmain(closure)) {
        const res = vm.result();

        var buf: [512]u8 = .{0} ** 512;

        vm.valueDump(res, buf[0..]);
        std.debug.print("RESULT: {s}\n", .{buf});
    }
}
