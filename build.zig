const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("gravity", "src/gravity.zig");
    lib.setBuildMode(mode);
    lib.setTarget(target);

    addcsources(lib);

    lib.install();

    const main_tests = b.addTest("src/gravity.zig");
    main_tests.setBuildMode(mode);
    main_tests.setTarget(target);
    addcsources(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn addcsources(lib: *std.build.LibExeObjStep) void {
    if (lib.target.isWindows()) {
        lib.linkSystemLibrary("shlwapi");
    }
    lib.linkLibC();
    lib.addIncludeDir("deps/gravity/src/shared");
    lib.addIncludeDir("deps/gravity/src/runtime");
    lib.addIncludeDir("deps/gravity/src/utils");
    lib.addIncludeDir("deps/gravity/src/compiler");
    lib.addIncludeDir("deps/gravity/src/optionals");
    lib.addCSourceFiles(&.{
        "deps/gravity/src/shared/gravity_value.c",
        "deps/gravity/src/shared/gravity_hash.c",
        "deps/gravity/src/shared/gravity_memory.c",
        "deps/gravity/src/runtime/gravity_core.c",
        "deps/gravity/src/runtime/gravity_vm.c",
        "deps/gravity/src/utils/gravity_debug.c",
        "deps/gravity/src/utils/gravity_json.c",
        "deps/gravity/src/utils/gravity_utils.c",
        "deps/gravity/src/compiler/gravity_ast.c",
        "deps/gravity/src/compiler/gravity_lexer.c",
        "deps/gravity/src/compiler/gravity_token.c",
        "deps/gravity/src/compiler/gravity_ircode.c",
        "deps/gravity/src/compiler/gravity_parser.c",
        "deps/gravity/src/compiler/gravity_codegen.c",
        "deps/gravity/src/compiler/gravity_visitor.c",
        "deps/gravity/src/compiler/gravity_compiler.c",
        "deps/gravity/src/compiler/gravity_optimizer.c",
        "deps/gravity/src/compiler/gravity_semacheck1.c",
        "deps/gravity/src/compiler/gravity_semacheck2.c",
        "deps/gravity/src/compiler/gravity_symboltable.c",
        "deps/gravity/src/optionals/gravity_opt_env.c",
        "deps/gravity/src/optionals/gravity_opt_file.c",
        "deps/gravity/src/optionals/gravity_opt_json.c",
        "deps/gravity/src/optionals/gravity_opt_math.c",
    }, &.{
        "-W",
        "-O3",
        "-fno-sanitize=undefined",
    });
}
