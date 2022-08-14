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
    link(b, main_tests, .{
        .encoder = true,
        .transcoder = true,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn link(b: *std.build.Builder, step: *std.build.LibExeObjStep, options: Options) void {
    if (options.encoder) {
        step.linkLibrary(buildEncoder(b));
        step.addCSourceFile(comptime thisDir() ++ "/src/encoder/wrapper.cpp", &.{});
        step.addIncludeDir(vendor_dir ++ "/encoder");
    }
    if (options.transcoder) {
        step.linkLibrary(buildTranscoder(b));
        step.addCSourceFile(comptime thisDir() ++ "/src/transcoder/wrapper.cpp", &.{});
        step.addIncludeDir(vendor_dir ++ "/transcoder");
    }
}

pub fn buildEncoder(b: *std.build.Builder) *std.build.LibExeObjStep {
    const encoder = b.addStaticLibrary("basisu_encoder", null);
    encoder.linkLibCpp();
    encoder.addCSourceFiles(
        &.{
            vendor_dir ++ "/encoder/basisu_backend.cpp",
            vendor_dir ++ "/encoder/basisu_basis_file.cpp",
            vendor_dir ++ "/encoder/basisu_bc7enc.cpp",
            vendor_dir ++ "/encoder/basisu_comp.cpp",
            vendor_dir ++ "/encoder/basisu_enc.cpp",
            vendor_dir ++ "/encoder/basisu_etc.cpp",
            vendor_dir ++ "/encoder/basisu_frontend.cpp",
            vendor_dir ++ "/encoder/basisu_gpu_texture.cpp",
            vendor_dir ++ "/encoder/basisu_kernels_sse.cpp",
            vendor_dir ++ "/encoder/basisu_opencl.cpp",
            vendor_dir ++ "/encoder/basisu_pvrtc1_4.cpp",
            vendor_dir ++ "/encoder/basisu_resample_filters.cpp",
            vendor_dir ++ "/encoder/basisu_resampler.cpp",
            vendor_dir ++ "/encoder/basisu_ssim.cpp",
            vendor_dir ++ "/encoder/basisu_uastc_enc.cpp",
            vendor_dir ++ "/encoder/jpgd.cpp",
            vendor_dir ++ "/encoder/pvpngreader.cpp",
        },
        &.{},
    );

    encoder.defineCMacro("BASISU_FORCE_DEVEL_MESSAGES", "0");
    encoder.defineCMacro("BASISD_SUPPORT_KTX2_ZSTD", "0");
    encoder.install();
    return encoder;
}

pub fn buildTranscoder(b: *std.build.Builder) *std.build.LibExeObjStep {
    const transcoder = b.addStaticLibrary("basisu_transcoder", null);
    transcoder.linkLibCpp();
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
