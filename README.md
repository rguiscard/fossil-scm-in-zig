# Fossil SCM with Zig build system #

**This is NOT the official [Fossil SCM](https://fossil-scm.org/).** There is no practical use of this repository. It is mainly a learning experience of compiling a C project with [Zig](https://ziglang.org/) build system.

### Original Fossil README.md ###

Please see [README.fossil.md](README.fossil.md)

## Overview ##

Original Fossil SCM can be compiled with typical `configure; make;` steps. Internally, it create configure files, creates several tools, preprocesses source codes, then do the final compilation, resulting a single `fossil` binary. It is a multi-step process. The goal of this repository is to recreate the same compilation process with Zig build system, namely `build.zig`. If possible, a single `zig build` can create `fossil` binary. Otherwise, it may take several steps to build the final binary.

## Build ##

### Create build directory ###

`mkdir build; cd build;`

### Configuration ###

`../configure --json --with-th1-docs --with-sqlite=tree`

### Build with default cc ###

Created `Makefile` include two variables: `BCC` and `TCC`. They are set to use `cc`. Run `make` to make sure fossil can be compiled with necessary libraries in the platform.

The compiled binary will be located in the same directory of Makefile, under `build` directory created above.

### Build with zig cc ###

`Zig cc` is a [drop-in replacement for GCC/Clang](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html). Therefore, let's replace cc with `zig cc` in Makefile and see. Go find `BCC` and `TCC` in Makefile and replace `cc` with `zig cc`. Then do `make` to compile. In my platform, there are errors aboud dns:

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

It seems to be an issue of resolv library version. Since it is only used in smtp of Fossil for email alert, it can be disable by adding `#define FOSSIL_OMIT_DNS 1` in `autoconfig.h`

To rebuild, after replacing `cc` with `zig cc` in Makefile, run `make clean; make;`

A new version of `fossil` is created and run `fossil version` to see it work.

## Change log ##

2023-11-06 replace `cc` with `zig cc` 
2023-11-06 import Fossil 2.22
2023-11-06 repository created
