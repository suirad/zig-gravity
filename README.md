# Zig wrapper for Gravity Lang

Wip wrapper and compiler for [Gravity Language](https://marcobambini.github.io/gravity/#/)

Example:
```zig
const std = @import("std");
const gravity = @import("gravity");

pub fn default_report_error(vm: ?*gravity.c.gravity_vm,
        err_type: c_uint, 
        msg: [*c]const u8,
        desc: gravity.c.error_desc_t,
        xdata: ?*anyopaque) callconv(.C) void {
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

test "basic test using wrappers" {
    var config = gravity.Delegate.init(.{ .error_callback = default_report_error });

    var compiler = try gravity.Compiler.init(&config);
    defer compiler.deinit();

    const closure = try compiler.run(source_code, 0, true, true);
    var vm = try gravity.Vm.init(&config);
    defer vm.deinit();

    compiler.transfer(&vm);

    if (vm.runmain(closure)) {
        const res = vm.result();

        var buf: [_]u8 = .{0} ** 512;

        vm.valueDump(res, buf[0..]);
        std.debug.print("RESULT: {s}\n", .{buf});
    }
}
```
