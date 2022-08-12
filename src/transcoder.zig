const std = @import("std");
pub const b = @import("binding.zig");
const testing = std.testing;

const Transcoder = @This();

handle: *b.BasisFile,

pub fn open(src: []const u8) Transcoder {
    b.basis_init();
    return .{ .handle = b.basis_open(src.ptr, @intCast(u32, src.len)) };
}

pub fn close(self: Transcoder) void {
    b.basis_close(self.handle);
}

pub fn getImageCount(self: Transcoder) u32 {
    return b.basis_get_images_count(self.handle);
}

pub fn getImageLevelCount(self: Transcoder, image_index: u32) u32 {
    return b.basis_get_levels_count(self.handle, image_index);
}

pub fn getImageLevelDescriptor(self: Transcoder, image_index: u32, level_index: u32) error{OutOfBoundsLevelIndex}!ImageLevelDescriptor {
    var desc: ImageLevelDescriptor = undefined;
    return if (b.basis_get_image_level_desc(
        self.handle,
        image_index,
        level_index,
        &desc.original_width,
        &desc.original_height,
        &desc.block_count,
    ))
        desc
    else
        error.OutOfBoundsLevelIndex;
}

pub fn calcTranscodedSize(self: Transcoder, image_index: u32, level_index: u32, format: TranscoderTextureFormat) error{OutOfBoundsLevelIndex}!u32 {
    var size: u32 = undefined;
    return if (b.basis_get_image_transcoded_size(self.handle, image_index, level_index, @enumToInt(format), &size))
        size
    else
        error.OutOfBoundsLevelIndex;
}

pub fn startTranscoding(self: Transcoder) error{Unknown}!void {
    if (!b.basis_start_transcoding(self.handle))
        return error.Unknown;
}

pub fn stopTranscoding(self: Transcoder) error{Unknown}!void {
    if (!b.basis_stop_transcoding(self.handle))
        return error.Unknown;
}

pub const TranscodeParams = struct {
    decode_flags: ?DecodeFlags = null,
    /// in blocks or pixels
    output_row_pitch: ?u32 = null,
    /// in pixels
    output_rows: ?u32 = null,
};

pub fn transcodeImage(
    self: Transcoder,
    out_buf: []u8,
    image_index: u32,
    level_index: u32,
    format: TranscoderTextureFormat,
    params: TranscodeParams,
) error{Unknown}!void {
    if (!b.basis_transcode_image(
        self.handle,
        out_buf.ptr,
        @intCast(u32, out_buf.len),
        image_index,
        level_index,
        @enumToInt(format),
        if (params.decode_flags) |f| f.cast() else 0,
        params.output_row_pitch orelse 0,
        params.output_rows orelse 0,
    )) return error.Unknown;
}

pub const ImageLevelDescriptor = struct {
    original_width: u32,
    original_height: u32,
    block_count: u32,
};

pub const DecodeFlags = packed struct {
    pvrtc_decode_to_next_pow_2: bool = false,
    transcode_alpha_data_to_opaque_formats: bool = false,
    bc1_forbid_three_color_blocks: bool = false,
    output_has_alpha_indices: bool = false,
    high_quality: bool = false,

    pub const Flag = enum(u32) {
        pvrtc_decode_to_next_pow_2 = 2,
        transcode_alpha_data_to_opaque_formats = 4,
        bc1_forbid_three_color_blocks = 8,
        output_has_alpha_indices = 16,
        high_quality = 32,
    };

    pub fn from(bits: u32) DecodeFlags {
        var value = DecodeFlags{};
        inline for (comptime std.meta.fieldNames(Flag)) |field_name| {
            if (bits & (@enumToInt(@field(Flag, field_name))) != 0) {
                @field(value, field_name) = true;
            }
        }
        return value;
    }

    pub fn cast(self: DecodeFlags) u32 {
        var value: u32 = 0;
        inline for (comptime std.meta.fieldNames(Flag)) |field_name| {
            if (@field(self, field_name)) {
                value |= @enumToInt(@field(Flag, field_name));
            }
        }
        return value;
    }
};

pub const BasisTextureFormat = enum(u1) {
    etc1s = 0,
    uastc4x4 = 1,

    pub fn isEnabled(self: BasisTextureFormat, transcoder_format: TranscoderTextureFormat) bool {
        return b.basis_is_format_supported(@enumToInt(self), @enumToInt(transcoder_format));
    }
};

pub const TranscoderTextureFormat = enum(u5) {
    etc1_rgb = 0,
    etc2_rgba = 1,
    bc1_rgb = 2,
    bc3_rgba = 3,
    bc4_r = 4,
    bc5_rg = 5,
    bc7_rgba = 6,
    bc7_alt = 7,
    pvrtc1_4_rgb = 8,
    pvrtc1_4_rgba = 9,
    astc_4x4_rgba = 10,
    atc_rgb = 11,
    atc_rgba = 12,
    rgba32 = 13,
    rgb565 = 14,
    bgr565 = 15,
    rgba4444 = 16,
    fxt1_rgb = 17,
    pvrtc2_4_rgb = 18,
    pvrtc2_4_rgba = 19,
    etc2_eac_r11 = 20,
    etc2_eac_rg11 = 21,

    pub fn isEnabled(
        self: TranscoderTextureFormat,
        basis_texture_format: BasisTextureFormat,
    ) bool {
        return basis_texture_format.isEnabled(self);
    }

    pub fn bytesPerBlockOrPixel(self: TranscoderTextureFormat) u5 {
        return switch (self) {
            .rgb565, .bgr565, .rgba4444 => return 2,
            .rgba32 => return 4,
            .etc1_rgb, .bc1_rgb, .bc4_r, .pvrtc1_4_rgb, .pvrtc1_4_rgba, .atc_rgb, .pvrtc2_4_rgb, .pvrtc2_4_rgba, .etc2_eac_r11 => 8,
            .bc7_rgba, .bc7_alt, .etc2_rgba, .bc3_rgba, .bc5_rg, .astc_4x4_rgba, .atc_rgba, .fxt1_rgb, .etc2_eac_rg11 => return 16,
        };
    }
};

pub const TranscoderBlockFormat = enum(u5) {
    etc1 = 0,
    etc2_rgba = 1,
    bc1 = 2,
    bc3 = 3,
    bc4 = 4,
    bc5 = 5,
    pvrtc1_4_rgb = 6,
    pvrtc1_4_rgba = 7,
    bc7 = 8,
    bc7_m5_color = 9,
    bc7_m5_alpha = 10,
    etc2_eac_a8 = 11,
    astc_4x4 = 12,
    atc_rgb = 13,
    atc_rgba_interpolated_alpha = 14,
    fxt1_rgb = 15,
    pvrtc2_4_rgb = 16,
    pvrtc2_4_rgba = 17,
    etc2_eac_r11 = 18,
    etc2_eac_rg11 = 19,
    indices = 20,
    rgb32 = 21,
    rgba32 = 23,
    a32 = 24,
    rgb565 = 25,
    bgr565 = 26,
    rgba4444_color = 27,
    rgba4444_alpha = 28,
    rgba4444_color_opaque = 29,
    rgba4444 = 30,
    uastc_4x4 = 31,
};

// Tests

const test_src_rgb = @import("basis_test_sources").src_rgb;

test "transcode" {
    const t = Transcoder.open(test_src_rgb);
    defer t.close();

    try std.testing.expectEqual(@as(u32, 1), t.getImageCount());
    try std.testing.expectEqual(@as(u32, 9), t.getImageLevelCount(0));

    const desc = try t.getImageLevelDescriptor(0, 0);
    try std.testing.expectEqual(
        desc.block_count * TranscoderTextureFormat.etc1_rgb.bytesPerBlockOrPixel(),
        try t.calcTranscodedSize(0, 0, .etc1_rgb),
    );
}

test "enums/flags" {
    try testing.expectEqual(@as(u32, 18), DecodeFlags.cast(.{
        .pvrtc_decode_to_next_pow_2 = true,
        .output_has_alpha_indices = true,
    }));
    try testing.expect(BasisTextureFormat.etc1s.isEnabled(.etc1_rgb));
}
