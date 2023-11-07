# Fossil SCM with Zig build system #

**This is NOT the official [Fossil SCM](https://fossil-scm.org/).** There is no practical use of this repository. It is mainly a learning experience of compiling a C project with [Zig](https://ziglang.org/) build system.

### Original Fossil README.md ###

Please see [README.fossil.md](README.fossil.md)

## Overview ##

Original Fossil SCM can be compiled with typical `configure; make;` steps. Internally, it runs configure, creates several tools, preprocesses source codes, then do the final compilation, resulting a single `fossil` binary. It is a [multi-step process](https://fossil-scm.org/home/doc/trunk/www/makefile.wiki). The goal of this repository is to recreate the same compilation process with Zig build system, namely `build.zig`. If possible, a single `zig build` can create `fossil` binary. Otherwise, it may take several steps to build the final binary.

## Build ##

### Create build directory ###

Inside Fossil SCM source code (e.g. `fossil-src-2.22/`), run `mkdir build; cd build;`

### Configuration ###

`../configure --json --with-th1-docs --with-sqlite=tree`

### Build with default cc ###

Created `Makefile` includes two variables: `BCC` and `TCC`. They are set to use `cc`. Run `make` to make sure fossil can be compiled with necessary libraries in the platform.

The compiled binary will be located in the same directory of Makefile, under `build` directory created above. All artifacts (.h, .o, etc.) will located under `build/bld` subdirectory by default.

### Build with zig cc ###

`Zig cc` is a [drop-in replacement for GCC/Clang](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html). Therefore, let's replace `cc` with `zig cc` in Makefile and see. Go find `BCC` and `TCC` in Makefile and replace `cc` with `zig cc`. Then do `make` to compile. In my platform, there are errors about DNS:

```
LLD Link... ld.lld: error: undefined symbol: __res_query
>>> referenced by smtp.c:71 (../src/smtp.c:71)
>>>               bld/smtp.o:(smtp_mx_host)

ld.lld: error: undefined symbol: ns_initparse
>>> referenced by smtp.c:74 (../src/smtp.c:74)
>>>               bld/smtp.o:(smtp_mx_host)

ld.lld: error: undefined symbol: ns_parserr
>>> referenced by smtp.c:81 (../src/smtp.c:81)
>>>               bld/smtp.o:(smtp_mx_host)

ld.lld: error: undefined symbol: __dn_expand
>>> referenced by smtp.c:94 (../src/smtp.c:94)
>>>               bld/smtp.o:(smtp_mx_host)
make: *** [../src/main.mk:743: fossil] Error 1
```

It seems to be an issue of resolv library version. Since it is only used in smtp of Fossil for email alert, it can be disabled by adding `#define FOSSIL_OMIT_DNS 1` in `autoconfig.h`

To rebuild, after replacing `cc` with `zig cc` in Makefile, run `make clean; make;`

A new version of `fossil` is created and run `fossil version` to see the result.

### build.zig ###

`build.zig` is at the heart of zig build system. It declares the building process similar to Makefile. One thing to note is that it declares the relationship of building process, but does not actually build it. Therefore, the output declared in `build.zig` cannot be used in `build.zig`. Any output from `build.zig` can be accessed after `zig build` is finished. The second thing to note is `zig build` is a shortcut to `zig build install`. And `install` in zig means installation to `./zig-out` subdirectory, not the system directory. `make install` usually installs into system directory. So it is fairly common to see the use of `zig build install` (or `zig build`) in development stage. It does not mean to install into `/usr/local/bin` or so, but just to `./zig-out/bin`. This may become important when we need to know where compiled or processed files are.

Details about the Zig build system will not be explained here, just to show a working version. Some good articles can be found by searching online. Zig is still under active development and API is changing. Document a few years old may not apply now. I will try to keep this one updated. Currently, this work targets Zig `0.11.0`.

### Build tools ###

There are tools under `tools` directory to be built first in order to process source code, namely `translate`, `mkindex`, `mkbuiltin`, `makeheaders`, `mkversion`, `codecheck1`. Let's build `tralsnate` first. Create a `build.zig` like this:

```
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_exe = b.addExecutable(.{
        .name = "translate",
        .root_source_file = null, // null because it is not zig source code
        .target = target,
        .optimize = optimize,
    });

    translate_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/translate.c", // relative path to C source code
        },
        .flags = &[_][]const u8 {}
    });
    translate_exe.linkLibC();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // Equal to b.installArtifact(translate_exe);
    const install_translate = b.addInstallArtifact(translate_exe, .{});
    b.getInstallStep().dependOn(&install_translate.step);
}
```

Run `zig build` will create `zig-out/bin/translate` tool. If it is preferred to put `translate` tool under `build/bld` as what Makefile does, installation path can be assigned (not sure the right way):

```
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.install_path = "./bld"; // default to ./bld directory

    const translate_exe = b.addExecutable(.{
        .name = "translate",
        .root_source_file = null, // null because it is not zig source code
        .target = target,
        .optimize = optimize,
    });

    translate_exe.addCSourceFile(.{
        .file = .{
            .path = "../tools/translate.c", // relative path to C source code
        },
        .flags = &[_][]const u8 {}
    });
    translate_exe.linkLibC();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // Assign to install_path
    const install_translate = b.addInstallArtifact(translate_exe, .{.dest_dir = .{.override = .{.custom = "./"}}});
    b.getInstallStep().dependOn(&install_translate.step);
}
```

Note that `translate_exe` is added into _install_step_, therefore, it will be executed (compiled) with `zig build install`. Other step can be created, say `zig build tools` to build tools only like this:

```
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // Equal to b.installArtifact(translate_exe);
    const install_translate = b.addInstallArtifact(translate_exe, .{.dest_dir = .{.override = .{.custom = "./"}}});
    b.getInstallStep().dependOn(&install_translate.step);

    const tools_step = b.step("tools", "build tools");
    tools_step.dependOn(&install_translate.step);
```

So besides adding `install_translate.step` into default install step (`b.getInstallStep()`), a `tools` step is created and `install_translate` is added. Run `zig build --help` can see the `tools` steps listed like this:

```
Usage: zig build [steps] [options]

Steps:
  install (default)            Copy build artifacts to prefix path
  uninstall                    Remove build artifacts from prefix path
  tools                        build tools
```

And run `zig build tools` will also create `translate` tool under `build/bld`.

### Translate source code ###

Fossil has several [preprocessing](https://fossil-scm.org/home/doc/trunk/www/makefile.wiki) steps and translation is one of it. It basically runs `translate src.c > src_.c`. To create such steps in `build.zig`, run step can be used:

```
    const add_c = b.addRunArtifact(translate_exe);
    add_c.addFileArg(.{.path = "../src/add.c"});
    _ = add_c.captureStdOut();

    const translate_step = b.step("translate", "translate source code");
    translate_step.dependOn(&add_c.step);
```

A run artifact using `translate` is created, and a file `../src/add.c` is added as first argument. Because `translate` tool output into stdout, the result needs to be captured. A translate step is also created and depends on this run step, and `zig build translate` will execute this preprocess.

Where is the output after running `zig build translate` ? It is inside `zig-cache`. You need to find the newly created `stdout` file. It looks like this after run `head -n 1 zig-cache/o/b39399aa0d315231a7cf44a22994ea8f/stdout`

```
#line 1 ".../src/add.c"
```

Again, it can be installed into designated directory `build/bld` like this:

```
    const add_c = b.addRunArtifact(translate_exe);
    add_c.addFileArg(.{.path = "../src/add.c"});
    const add_c_path = add_c.captureStdOut();

    const install_add_c = b.addInstallFile(add_c_path, "./add_.c");

    const translate_step = b.step("translate", "translate source code");
    translate_step.dependOn(&install_add_c.step);
```

`captureStdOut()` will return a path to the content of stdout, and it can be installed into a designated path with `addInstallFile()`. Please note that this `add_c_path` does not exist yet in `build.zig`. If you try to print its value, it will either be null or causes error. This value is only available after `zig build` is finished. Therefore, it can only be used as a way to pass information.

To work at many source codes, try this:

```
    // translate step to preprocess source code
    const translate_step = b.step("translate", "translate source code");

    const src = [_][]const u8{"add", "ajax"};

    inline for(src) |file| {
        std.log.info("Processing {s}\n", .{file});
        const file_c = b.addRunArtifact(translate_exe);
        file_c.addFileArg(.{.path = "../src/" ++ file ++ ".c"});
        const file_c_path = file_c.captureStdOut();
        const install_file_c = b.addInstallFile(file_c_path, "./" ++ file ++ "_.c");
        translate_step.dependOn(&install_file_c.step);
    }
```

This version puts previous one into a loop. Please note the use of `inline for` because of comptime. Otherwise, it will complain `file` is not compiletime-known. Another note is that this `translate` step depends on `translate_exe`, but not `install_translate`. Therefore, it still compiles `translate` tool, but does not put it into `build/bld` directory. The whole process still works because Zig know where the compiled `translate` tool is inside _zig-cache_ directory. Thus, there is no need to explicitly put `translate` to `build/bld` directory. In other word, the part of `install_translate` can be removed in the future.

### Preprocess: translate & mkindex ###

`mkindex` will take all output of `translate` and extract into a `page_index.h`. Therefore, it is good to combine these two tools togehter into a preprocess step. 

First, create these two tools:

```
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
```

Build the args for each tool and create dependencies:

```
    // preprocess step to translate and mkindex
    const preprocess_step = b.step("preprocess", "translate and mkindex source code");

    // mkindex
    const mkindex = b.addRunArtifact(mkindex_exe);

    const src = [_][]const u8{"add", "ajax"};

    inline for(src) |file| {
        // translate
        std.log.info("translate... {s}\n", .{file});
        const file_c = b.addRunArtifact(translate_exe);
        file_c.addFileArg(.{.path = "../src/" ++ file ++ ".c"});
        const file_c_path = file_c.captureStdOut();
        const install_file_c = b.addInstallFile(file_c_path, "./" ++ file ++ "_.c");

        // add translate to preprocess_step
        preprocess_step.dependOn(&install_file_c.step);

        // build up args for mkindex
        mkindex.addFileArg(file_c_path);
    }

    // mkindex
    const mkindex_path = mkindex.captureStdOut();
    const install_mkindex = b.addInstallFile(mkindex_path, "page_index.h");

    // add mkindex to preprocess_step
    preprocess_step.dependOn(&install_mkindex.step);
```

Now, run `zig build preprocess` will run both `translate` and `mkindex` and output into `build/bld` directory.

### Preprocess: mkversion ###

It runs as `mkversion manifest.uuid manifest VERSION > VERSION.h`. It follows previous `translate`:

```
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
```

It is now quite straight forward to build and run these tools.

### Preprocess: mkbuiltin ###

`mkbuiltin` works similar to `mkversion`

```
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
```

### Preprocess: makeheaders ###

[makeheaders](https://fossil-scm.org/home/doc/trunk/tools/makeheaders.html) works slight different. It takes `addArg` instead of `addFileArg`. And for some reason, it only works in `ReleaseFast` or `ReleaseSmall` mode.

```
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
```

### Preprocess: codecheck1 ###

`codecheck1` is optional, and works similar to `translate` or `mkindex`. So they can be put together.

```
    // translate and mkindex are omitted ...

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
```

## What's next ##

There is no plan for next steps. Fossil SCM provides ways to create [new features](https://fossil-scm.org/home/doc/trunk/www/adding_code.wiki), either a new command or a new web page. Therefore, it is easy to customize. The only possible next step is to see whether Zig build system can also replace `configure` step. But it is not an urgent task for now.

## Change log ##

- 2023-11-06 import Fossil 2.22
- 2023-11-06 repository created

## Why host on Github ? ###

I also keep asking myself this question frequently. Fossil SCM can host itself easily. The answer I can come out with is the social effect of github. With single account, I can interact with all kinds of repositories. So it is less about Fossil vs Git, but more about the platform providing social effect. Github allows a project to be seen by people unknown to me. It is a platform for publishing codes.
