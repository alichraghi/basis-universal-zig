const std = @import("std");

const vendor_dir = thisDir() ++ "/vendor";

pub const pkg = std.build.Pkg{
    .name = "basis-universal",
    .source = .{
        .path = "src/main.zig",
    },
};

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const main_tests = b.addTest(comptime thisDir() ++ "/src/main.zig");
    main_tests.setBuildMode(mode);
    main_tests.addPackagePath("basis_test_sources", thisDir() ++ "/test/basis_sources.zig");
    link(b, main_tests, .{
        .encoder = true,
        .transcoder = true,
    });
    main_tests.use_stage1 = false;

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn link(b: *std.build.Builder, step: *std.build.LibExeObjStep, options: Options) void {
    if (options.transcoder) {
        step.linkLibrary(buildBasisuTranscoder(b));
        step.addCSourceFile(comptime thisDir() ++ "/src/binding.cpp", &.{});
        step.addIncludeDir(vendor_dir ++ "/transcoder");
    }
}

pub fn buildBasisuTranscoder(b: *std.build.Builder) *std.build.LibExeObjStep {
    const transcoder = b.addStaticLibrary("basisu_transcoder", null);
    transcoder.linkLibCpp();
    transcoder.use_stage1 = false;
    transcoder.addCSourceFiles(
        &.{
            vendor_dir ++ "/transcoder/basisu_transcoder.cpp",
        },
        &.{},
    );
    transcoder.defineCMacro("BASISD_SUPPORT_KTX2_ZSTD", "0");
    transcoder.install();
    return transcoder;
}

pub const Options = struct {
    encoder: bool,
    transcoder: bool,
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
