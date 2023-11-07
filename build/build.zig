const std = @import("std");

const src = [_][]const u8{"add", "ajax"};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.install_path = "./bld";

    // #### translate, mkindex & codecheck1 ####

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

    const mkindex_exe = b.addExecutable(.{
        .name = "mkindex",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    mkindex_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/mkindex.c",
        },
        .flags = &[_][]const u8 {}
    });

    mkindex_exe.linkLibC();

    const codecheck1_exe = b.addExecutable(.{
        .name = "codecheck1",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    codecheck1_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/codecheck1.c",
        },
        .flags = &[_][]const u8 {}
    });

    codecheck1_exe.linkLibC();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // Equal to b.installArtifact(translate_exe);
    // const install_translate = b.addInstallArtifact(translate_exe, .{.dest_dir = .{.override = .{.custom = "./"}}});
    // b.getInstallStep().dependOn(&install_translate.step);

    // preprocess step to translate and mkindex
    const preprocess_step = b.step("preprocess", "translate and mkindex source code");

    // mkindex
    const mkindex = b.addRunArtifact(mkindex_exe);

    // codecheck1
    const codecheck1 = b.addRunArtifact(codecheck1_exe);

    inline for(src) |file| {
        // translate
        std.log.info("translate... {s}\n", .{file});
        const file_c = b.addRunArtifact(translate_exe);
        file_c.addFileArg(.{.path = "../src/" ++ file ++ ".c"});
        const file_c_path = file_c.captureStdOut();
        const install_file_c = b.addInstallFile(file_c_path, "./" ++ file ++ "_.c");

        preprocess_step.dependOn(&install_file_c.step);

        // build up args for mkindex
        mkindex.addFileArg(file_c_path);

        // build up args for codecheck1
        codecheck1.addFileArg(file_c_path);
    }

    // mkindex output
    const mkindex_path = mkindex.captureStdOut();
    const install_mkindex = b.addInstallFile(mkindex_path, "page_index.h");

    preprocess_step.dependOn(&install_mkindex.step);
    preprocess_step.dependOn(&codecheck1.step);

    // #### mkversion ####

    const mkversion_exe = b.addExecutable(.{
        .name = "mkversion",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    mkversion_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/mkversion.c",
        },
        .flags = &[_][]const u8 {}
    });
    mkversion_exe.linkLibC();

    // mkversion step to preprocess source code
    const mkversion_step = b.step("mkversion", "make VERSION.h");

    std.log.info("mkversion...\n", .{});
    const mkversion = b.addRunArtifact(mkversion_exe);
    const version_files = [_][]const u8{"manifest.uuid", "manifest", "VERSION"};
    inline for(version_files) |file| {
      mkversion.addFileArg(.{.path = "../" ++ file});
    }
    const version_stdout = mkversion.captureStdOut();
    const install_version = b.addInstallFile(version_stdout, "VERSION.h");
    mkversion_step.dependOn(&install_version.step);

    // add mkversion to preprocess_step
    preprocess_step.dependOn(&install_version.step);

    // #### mkbuiltin ####

    const mkbuiltin_exe = b.addExecutable(.{
        .name = "mkbuiltin",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    mkbuiltin_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/mkbuiltin.c",
        },
        .flags = &[_][]const u8 {}
    });
    mkbuiltin_exe.linkLibC();

    // mkbuiltin step to preprocess source code
    const mkbuiltin_step = b.step("mkbuiltin", "make builtin data");

    std.log.info("mkbuiltin...\n", .{});
    const mkbuiltin = b.addRunArtifact(mkbuiltin_exe);
    const builtin_files = [_][]const u8{"extsrc/pikchr-worker.js", "extsrc/pikchr.js", "extsrc/pikchr.wasm"};
    inline for(builtin_files) |file| {
      mkbuiltin.addFileArg(.{.path = "../" ++ file});
    }
    const builtin_stdout = mkbuiltin.captureStdOut();
    const install_builtin = b.addInstallFile(builtin_stdout, "builtin_data.h");
    mkbuiltin_step.dependOn(&install_builtin.step);

    // add mkversion to preprocess_step
    preprocess_step.dependOn(&install_builtin.step);

    // #### makeheaders ####

    const makeheaders_exe = b.addExecutable(.{
        .name = "makeheaders",
        .root_source_file = null,
        .target = target,
        .optimize = std.builtin.Mode.ReleaseFast, // only work for ReleaseSmall and ReleaseFast; otherwise it will failed
    });

    makeheaders_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/makeheaders.c",
        },
        .flags = &[_][]const u8 {}
    });
    makeheaders_exe.linkLibC();

    // makeheaders step to preprocess source code
    const makeheaders_step = b.step("makeheaders", "make headers");

    std.log.info("makeheaders...\n", .{});
    const makeheaders = b.addRunArtifact(makeheaders_exe);
    const files = src ++ [_][]const u8{};
    inline for(files) |file| {
      makeheaders.addArg("./bld/" ++ file ++ "_.c:./bld/" ++ file ++ ".h");
    }
    makeheaders_step.dependOn(&makeheaders.step);

    // add mkversion to preprocess_step
    preprocess_step.dependOn(&makeheaders.step);

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
