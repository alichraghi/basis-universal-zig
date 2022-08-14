pub usingnamespace @import("encoder.zig");
pub usingnamespace @import("transcoder.zig");

const t = @import("transcoder.zig");
const e = @import("encoder.zig");

pub const BasisTextureFormat = enum(u1) {
    etc1s = 0,
    uastc4x4 = 1,
};

// Test

const std = @import("std");

test "reference decls" {
    std.testing.refAllDeclsRecursive(@This());
}

test "encode/transcode" {
    // Encode
    e.init_encoder();

    const params = e.CompressorParams.init(1);
    params.setGenerateMipMaps(true);
    params.setBasisFormat(.uastc4x4);
    params.setPackUASTCFlags(.{ .fastest = true });
    defer params.deinit();

    const image = params.getImageSource(0);
    image.fill(@embedFile("../test/ziggy.png"), 379, 316, 4);

    const comp = try e.Compressor.init(params);
    try comp.process();

    // Transcode
    t.init_transcoder();

    const trans = t.Transcoder.init(comp.output());
    defer trans.deinit();

    var out_buf = try std.testing.allocator.alloc(u8, try trans.calcTranscodedSize(0, 0, .astc_4x4_rgba));
    defer std.testing.allocator.free(out_buf);

    try trans.startTranscoding();

    try trans.transcode(out_buf, 0, 0, .astc_4x4_rgba, .{});

    try trans.stopTranscoding();
}
