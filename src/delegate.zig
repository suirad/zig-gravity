const std = @import("std");
const meta = std.meta;
const gravity = @import("gravity.zig");
const c = gravity.c;

pub const Delegate = struct {
    inner: c.gravity_delegate_t,

    pub fn init(args: anytype) Delegate {
        var ret = c.gravity_delegate_t{
            .error_callback = gravity.default_report_error,
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

        inline for (comptime meta.fields(@TypeOf(args))) |arg| {
            inline for (comptime meta.fields(c.gravity_delegate_t)) |field| {
                comptime if (std.mem.eql(u8, arg.name, field.name)) {
                    @field(ret, arg.name) = @field(args, arg.name);
                };
            }
        }

        return .{ .inner = ret };
    }
};
