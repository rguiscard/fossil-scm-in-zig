const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.install_path = "./bld";

    const translate_exe = b.addExecutable(.{
        .name = "translate",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    translate_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/translate.c",
        },
        .flags = &[_][]const u8 {}
    });
    translate_exe.linkLibC();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // Equal to b.installArtifact(translate_exe);
    const install_translate = b.addInstallArtifact(translate_exe, .{.dest_dir = .{.override = .{.custom = "./"}}});
    b.getInstallStep().dependOn(&install_translate.step);

    const tools_step = b.step("tools", "build tools");
    tools_step.dependOn(&install_translate.step);

    //const x = b.addRunArtifact(translate_exe);
    //x.addFileArg(.{.path = "../src/add.c"});
    //_ = x.captureStdOut();

    //const y = b.addRunArtifact(translate_exe);
    //y.addFileArg(.{.path = "../src/ajax.c"});
    //_ = y.captureStdOut();

    //const pack_step = b.step("pack", "Packs the game and assets together");
    //pack_step.dependOn(&x.step);
    //pack_step.dependOn(&y.step);

    //std.log.info("All your codebase are belong to us. {s}", .{b.install_path});

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    // const run_cmd = b.addRunArtifact(translate);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    // run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    // const unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
