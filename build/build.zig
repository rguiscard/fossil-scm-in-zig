const std = @import("std");

const src = [_][]const u8{
  "add",
  "ajax",
  "alerts",
  "allrepo",
  "attach",
  "backlink",
  "backoffice",
  "bag",
  "bisect",
  "blob",
  "branch",
  "browse",
  "builtin",
  "bundle",
  "cache",
  "capabilities",
  "captcha",
  "cgi",
  "chat",
  "checkin",
  "checkout",
  "clearsign",
  "clone",
  "color",
  "comformat",
  "configure",
  "content",
  "cookies",
  "db",
  "delta",
  "deltacmd",
  "deltafunc",
  "descendants",
  "diff",
  "diffcmd",
  "dispatch",
  "doc",
  "encode",
  "etag",
  "event",
  "extcgi",
  "export",
  "file",
  "fileedit",
  "finfo",
  "foci",
  "forum",
  "fshell",
  "fusefs",
  "fuzz",
  "glob",
  "graph",
  "gzip",
  "hname",
  "hook",
  "http",
  "http_socket",
  "http_transport",
  "import",
  "info",
  "interwiki",
  "json",
  "json_artifact",
  "json_branch",
  "json_config",
  "json_diff",
  "json_dir",
  "json_finfo",
  "json_login",
  "json_query",
  "json_report",
  "json_status",
  "json_tag",
  "json_timeline",
  "json_user",
  "json_wiki",
  "leaf",
  "loadctrl",
  "login",
  "lookslike",
  "main",
  "manifest",
  "markdown",
  "markdown_html",
  "md5",
  "merge",
  "merge3",
  "moderate",
  "name",
  "patch",
  "path",
  "piechart",
  "pikchrshow",
  "pivot",
  "popen",
  "pqueue",
  "printf",
  "publish",
  "purge",
  "rebuild",
  "regexp",
  "repolist",
  "report",
  "rss",
  "schema",
  "search",
  "security_audit",
  "setup",
  "setupuser",
  "sha1",
  "sha1hard",
  "sha3",
  "shun",
  "sitemap",
  "skins",
  "smtp",
  "sqlcmd",
  "stash",
  "stat",
  "statrep",
  "style",
  "sync",
  "tag",
  "tar",
  "terminal",
  "th_main",
  "timeline",
  "tkt",
  "tktsetup",
  "undo",
  "unicode",
  "unversioned",
  "update",
  "url",
  "user",
  "utf8",
  "util",
  "verify",
  "vfile",
  "wiki",
  "wikiformat",
  "winfile",
  "winhttp",
  "xfer",
  "xfersetup",
  "zip",
  "http_ssl",
};

const builtin_files = [_][]const u8{
    "extsrc/pikchr-worker.js",
    "extsrc/pikchr.js",
    "extsrc/pikchr.wasm",
    "skins/ardoise/css.txt",
    "skins/ardoise/details.txt",
    "skins/ardoise/footer.txt",
    "skins/ardoise/header.txt",
    "skins/black_and_white/css.txt",
    "skins/black_and_white/details.txt",
    "skins/black_and_white/footer.txt",
    "skins/black_and_white/header.txt",
    "skins/blitz/css.txt",
    "skins/blitz/details.txt",
    "skins/blitz/footer.txt",
    "skins/blitz/header.txt",
    "skins/blitz/ticket.txt",
    "skins/darkmode/css.txt",
    "skins/darkmode/details.txt",
    "skins/darkmode/footer.txt",
    "skins/darkmode/header.txt",
    "skins/default/css.txt",
    "skins/default/details.txt",
    "skins/default/footer.txt",
    "skins/default/header.txt",
    "skins/eagle/css.txt",
    "skins/eagle/details.txt",
    "skins/eagle/footer.txt",
    "skins/eagle/header.txt",
    "skins/khaki/css.txt",
    "skins/khaki/details.txt",
    "skins/khaki/footer.txt",
    "skins/khaki/header.txt",
    "skins/original/css.txt",
    "skins/original/details.txt",
    "skins/original/footer.txt",
    "skins/original/header.txt",
    "skins/plain_gray/css.txt",
    "skins/plain_gray/details.txt",
    "skins/plain_gray/footer.txt",
    "skins/plain_gray/header.txt",
    "skins/xekri/css.txt",
    "skins/xekri/details.txt",
    "skins/xekri/footer.txt",
    "skins/xekri/header.txt",
    "src/accordion.js",
    "src/alerts/bflat2.wav",
    "src/alerts/bflat3.wav",
    "src/alerts/bloop.wav",
    "src/alerts/plunk.wav",
    "src/ci_edit.js",
    "src/copybtn.js",
    "src/default.css",
    "src/diff.js",
    "src/diff.tcl",
    "src/forum.js",
    "src/fossil.bootstrap.js",
    "src/fossil.confirmer.js",
    "src/fossil.copybutton.js",
    "src/fossil.diff.js",
    "src/fossil.dom.js",
    "src/fossil.fetch.js",
    "src/fossil.numbered-lines.js",
    "src/fossil.page.brlist.js",
    "src/fossil.page.chat.js",
    "src/fossil.page.fileedit.js",
    "src/fossil.page.forumpost.js",
    "src/fossil.page.pikchrshow.js",
    "src/fossil.page.pikchrshowasm.js",
    "src/fossil.page.whistory.js",
    "src/fossil.page.wikiedit.js",
    "src/fossil.pikchr.js",
    "src/fossil.popupwidget.js",
    "src/fossil.storage.js",
    "src/fossil.tabs.js",
    "src/fossil.wikiedit-wysiwyg.js",
    "src/graph.js",
    "src/hbmenu.js",
    "src/href.js",
    "src/login.js",
    "src/markdown.md",
    "src/menu.js",
    "src/scroll.js",
    "src/skin.js",
    "src/sorttable.js",
    "src/sounds/0.wav",
    "src/sounds/1.wav",
    "src/sounds/2.wav",
    "src/sounds/3.wav",
    "src/sounds/4.wav",
    "src/sounds/5.wav",
    "src/sounds/6.wav",
    "src/sounds/7.wav",
    "src/sounds/8.wav",
    "src/sounds/9.wav",
    "src/sounds/a.wav",
    "src/sounds/b.wav",
    "src/sounds/c.wav",
    "src/sounds/d.wav",
    "src/sounds/e.wav",
    "src/sounds/f.wav",
    "src/style.admin_log.css",
    "src/style.chat.css",
    "src/style.fileedit.css",
    "src/style.pikchrshow.css",
    "src/style.wikiedit.css",
    "src/tree.js",
    "src/useredit.js",
    "src/wiki.wiki",
};

const cflags = [_][]const u8{
    "-Wall",
    "-Wdeclaration-after-statement",
    "-DFOSSIL_ENABLE_JSON",
    "-DFOSSIL_ENABLE_TH1_DOCS",
    "-DFOSSIL_DYNAMIC_BUILD=1",
    "-DHAVE_AUTOCONFIG_H",
};

const sqlite_options = [_][]const u8{
    "-DNDEBUG=1",
    "-DSQLITE_DQS=0",
    "-DSQLITE_THREADSAFE=0",
    "-DSQLITE_DEFAULT_MEMSTATUS=0",
    "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1",
    "-DSQLITE_LIKE_DOESNT_MATCH_BLOBS",
    "-DSQLITE_OMIT_DECLTYPE",
    "-DSQLITE_OMIT_DEPRECATED",
    "-DSQLITE_OMIT_PROGRESS_CALLBACK",
    "-DSQLITE_OMIT_SHARED_CACHE",
    "-DSQLITE_OMIT_LOAD_EXTENSION",
    "-DSQLITE_MAX_EXPR_DEPTH=0",
    "-DSQLITE_ENABLE_LOCKING_STYLE=0",
    "-DSQLITE_DEFAULT_FILE_FORMAT=4",
    "-DSQLITE_ENABLE_EXPLAIN_COMMENTS",
    "-DSQLITE_ENABLE_FTS4",
    "-DSQLITE_ENABLE_DBSTAT_VTAB",
    "-DSQLITE_ENABLE_FTS5",
    "-DSQLITE_ENABLE_STMTVTAB",
    "-DSQLITE_HAVE_ZLIB",
    "-DSQLITE_ENABLE_DBPAGE_VTAB",
    "-DSQLITE_TRUSTED_SCHEMA=0",
    "-DHAVE_USLEEP",
};

const shell_options = [_][]const u8{
    "-DNDEBUG=1",
    "-DSQLITE_DQS=0",
    "-DSQLITE_THREADSAFE=0",
    "-DSQLITE_DEFAULT_MEMSTATUS=0",
    "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1",
    "-DSQLITE_LIKE_DOESNT_MATCH_BLOBS",
    "-DSQLITE_OMIT_DECLTYPE",
    "-DSQLITE_OMIT_DEPRECATED",
    "-DSQLITE_OMIT_PROGRESS_CALLBACK",
    "-DSQLITE_OMIT_SHARED_CACHE",
    "-DSQLITE_OMIT_LOAD_EXTENSION",
    "-DSQLITE_MAX_EXPR_DEPTH=0",
    "-DSQLITE_ENABLE_LOCKING_STYLE=0",
    "-DSQLITE_DEFAULT_FILE_FORMAT=4",
    "-DSQLITE_ENABLE_EXPLAIN_COMMENTS",
    "-DSQLITE_ENABLE_FTS4",
    "-DSQLITE_ENABLE_DBSTAT_VTAB",
    "-DSQLITE_ENABLE_FTS5",
    "-DSQLITE_ENABLE_STMTVTAB",
    "-DSQLITE_HAVE_ZLIB",
    "-DSQLITE_ENABLE_DBPAGE_VTAB",
    "-DSQLITE_TRUSTED_SCHEMA=0",
    "-DHAVE_USLEEP",
    "-Dmain=sqlite3_shell",
    "-DSQLITE_SHELL_IS_UTF8=1",
    "-DSQLITE_OMIT_LOAD_EXTENSION=1",
    "-DUSE_SYSTEM_SQLITE=0",
    "-DSQLITE_SHELL_DBNAME_PROC=sqlcmd_get_dbname",
    "-DSQLITE_SHELL_INIT_PROC=sqlcmd_init_proc",
};

const pikchr_options = [_][]const u8 {
    "-DPIKCHR_TOKEN_LIMIT=10000",
};

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

    // mkindex
    const mkindex = b.addRunArtifact(mkindex_exe);

    // codecheck1
    const codecheck1 = b.addRunArtifact(codecheck1_exe);

    inline for(src) |file| {
        // translate
        const file_c = b.addRunArtifact(translate_exe);
        file_c.addFileArg(.{.path = "../src/" ++ file ++ ".c"});
        const file_c_path = file_c.captureStdOut();
        const install_file_c = b.addInstallFile(file_c_path, "./" ++ file ++ "_.c");

        // build up args for mkindex
        mkindex.addFileArg(file_c_path);
        mkindex.step.dependOn(&install_file_c.step);

        // build up args for codecheck1
        codecheck1.addFileArg(file_c_path);
        codecheck1.step.dependOn(&install_file_c.step);
    }

    // mkindex output
    const mkindex_path = mkindex.captureStdOut();
    const install_mkindex = b.addInstallFile(mkindex_path, "page_index.h");

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

    const mkversion = b.addRunArtifact(mkversion_exe);
    const version_files = [_][]const u8{"manifest.uuid", "manifest", "VERSION"};
    inline for(version_files) |file| {
      mkversion.addFileArg(.{.path = "../" ++ file});
    }
    const version_stdout = mkversion.captureStdOut();
    const install_version = b.addInstallFile(version_stdout, "VERSION.h");

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

    const mkbuiltin = b.addRunArtifact(mkbuiltin_exe);
    inline for(builtin_files) |file| {
      mkbuiltin.addFileArg(.{.path = "../" ++ file});
    }
    const builtin_stdout = mkbuiltin.captureStdOut();
    const install_builtin = b.addInstallFile(builtin_stdout, "builtin_data.h");

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

    const makeheaders = b.addRunArtifact(makeheaders_exe);
    inline for(src) |file| {
      makeheaders.addArg("./bld/" ++ file ++ "_.c:./bld/" ++ file ++ ".h");
    }
    const extra_headers = [_][]const u8{
        "../extsrc/pikchr.c:bld/pikchr.h",
        "../extsrc/sqlite3.h",
        "../src/th.h",
        "bld/VERSION.h",
    };
    inline for(extra_headers) |file| {
      makeheaders.addArg(file);
    }

    makeheaders.step.dependOn(&install_mkindex.step);
    makeheaders.step.dependOn(&codecheck1.step);
    makeheaders.step.dependOn(&install_version.step);
    makeheaders.step.dependOn(&install_builtin.step);

    // touch bld/headers
    const touch = b.addSystemCommand(&[_][]const u8{
      "touch", "bld/headers",
    });

    touch.step.dependOn(&makeheaders.step);

    // fossil binary
    const fossil_exe = b.addExecutable(.{
        .name = "fossil",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    fossil_exe.addCSourceFile(.{
        .file = .{ .path = "../extsrc/sqlite3.c" },
        .flags = &(cflags ++ sqlite_options),
    });

    fossil_exe.addCSourceFile(.{
        .file = .{ .path = "../extsrc/linenoise.c" },
        .flags = &cflags,
    });

    fossil_exe.addCSourceFile(.{
        .file = .{ .path = "../extsrc/pikchr.c" },
        .flags = &(cflags ++ pikchr_options),
    });

    fossil_exe.addCSourceFile(.{
        .file = .{ .path = "../extsrc/shell.c" },
        .flags = &(cflags ++ shell_options),
    });

    const extsrc = [_][]const u8{"src/th.c", "src/th_lang.c", "src/th_tcl.c", "extsrc/cson_amalgamation.c"};
    inline for(extsrc) |file| {
        fossil_exe.addCSourceFile(.{
            .file = .{ .path = "../" ++ file },
            .flags = &cflags,
        });
    }

    inline for(src) |file| {
        fossil_exe.addCSourceFile(.{
            .file = .{ .path = "bld/" ++ file ++ "_.c"},
            .flags = &cflags,
        });
    }

    fossil_exe.linkLibC();
    fossil_exe.linkSystemLibrary("m");
    fossil_exe.linkSystemLibrary("resolv");
    fossil_exe.linkSystemLibrary("ssl");
    fossil_exe.linkSystemLibrary("crypto");
    fossil_exe.linkSystemLibrary("z");
    fossil_exe.linkSystemLibrary("dl");

    // .path doesn't work for unknown reason. 
    // fossil_exe.addIncludePath(.{.path = "./"});
    // fossil_exe.addIncludePath(.{.path = "bld"});
    // fossil_exe.addIncludePath(.{.path = "../src"});
    // fossil_exe.addIncludePath(.{.path = "../extsrc"});
    fossil_exe.addIncludePath(.{.cwd_relative = "./"});
    fossil_exe.addIncludePath(.{.cwd_relative = "bld"});
    fossil_exe.addIncludePath(.{.cwd_relative = "../src"});
    fossil_exe.addIncludePath(.{.cwd_relative = "../extsrc"});

    fossil_exe.step.dependOn(&touch.step);

    const install_fossil = b.addInstallArtifact(fossil_exe, .{});
    b.getInstallStep().dependOn(&install_fossil.step);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(fossil_exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

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
