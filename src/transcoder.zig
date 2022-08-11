const std = @import("std");
const testing = std.testing;
pub const binding = @import("binding.zig");

fn prepare_transcoding() void {
    binding.basisu_transcoder_init();
}

const Transcoder = @This();

handle: *binding.BasisuTranscoder,

pub fn init() Transcoder {
    return .{ .handle = binding.transcoder_init() };
}

pub fn deinit(self: Transcoder) void {
    binding.transcoder_deinit(self.handle);
}

pub fn validateFileChecksums(self: Transcoder, data: []const u8, full_validation: bool) bool {
    return binding.transcoder_validate_file_checksums(self.handle, data.ptr, @intCast(u32, data.len), full_validation);
}

pub fn validateHeader(self: Transcoder, data: []const u8) bool {
    return binding.transcoder_validate_header(self.handle, data.ptr, @intCast(u32, data.len));
}

pub fn getTextureType(self: Transcoder, data: []const u8) BasisTextureType {
    return @intToEnum(BasisTextureType, binding.transcoder_get_texture_type(self.handle, data.ptr, @intCast(u32, data.len)));
}

pub fn getTextureFormat(self: Transcoder, data: []const u8) BasisTextureFormat {
    return @intToEnum(BasisTextureFormat, binding.transcoder_get_tex_format(self.handle, data.ptr, @intCast(u32, data.len)));
}

pub fn getUserData(self: Transcoder, data: []const u8) error{Unknown}![2]u32 {
    var ud: [2]u32 = undefined;
    return if (binding.transcoder_get_userdata(self.handle, data.ptr, @intCast(u32, data.len), &ud[0], &ud[1]))
        ud
    else
        error.Unknown;
}

pub fn getImageCount(self: Transcoder, data: []const u8) u32 {
    return binding.transcoder_get_total_images(self.handle, data.ptr, @intCast(u32, data.len));
}

pub fn getImageLevelCount(self: Transcoder, data: []const u8, image_index: u32) u32 {
    return binding.transcoder_get_total_image_levels(self.handle, data.ptr, @intCast(u32, data.len), image_index);
}

pub fn startTranscoding(self: Transcoder, data: []const u8) error{Unknown}!void {
    if (!binding.transcoder_start_transcoding(self.handle, data.ptr, @intCast(u32, data.len)))
        return error.Unknown;
}

pub fn stopTranscoding(self: Transcoder) error{Unknown}!void {
    if (!binding.transcoder_stop_transcoding(self.handle))
        return error.Unknown;
}

pub const TranscodeError = error{
    UnsupportedFormat,
    OutOfBoundsLevelIndex,
    Unknown,
};

pub fn transcodeImageLevel(self: Transcoder, out_buf: []u8, data: []const u8, format: TranscoderTextureFormat, params: TranscodeParams) TranscodeError!void {
    if (!self.getTextureFormat(data).isEnabled(format)) {
        return error.UnsupportedFormat;
    }

    if (!binding.transcoder_transcode_image_level(
        self.handle,
        data.ptr,
        @intCast(u32, data.len),
        params.image_index,
        params.level_index,
        out_buf.ptr,
        @intCast(u32, out_buf.len),
        @enumToInt(format),
        if (params.decode_flags) |f| f.cast() else 0,
        params.output_row_pitch orelse 0,
        null,
        params.output_rows orelse 0,
    )) return error.Unknown;
}

pub fn getFileInfo(self: Transcoder, data: []const u8) error{ InvalidTextureFormat, Unknown }!FileInfo {
    var fi: binding.FileInfo = undefined;
    if (binding.transcoder_get_file_info(self.handle, data.ptr, @intCast(u32, data.len), &fi)) {
        if (fi.m_tex_format == -1)
            return error.InvalidTextureFormat;

        return FileInfo{
            .version = fi.m_version,
            .total_header_size = fi.m_total_header_size,
            .total_selectors = fi.m_total_selectors,
            .selector_codebook_offset = fi.m_selector_codebook_ofs,
            .selector_codebook_size = fi.m_selector_codebook_size,
            .tables_offset = fi.m_tables_ofs,
            .tables_size = fi.m_tables_size,
            .slices_size = fi.m_slices_size,
            .texture_type = @intToEnum(BasisTextureType, fi.m_tex_type),
            .us_per_frame = fi.m_us_per_frame,
            .total_images = fi.m_total_images,
            .userdata_0 = fi.m_userdata0,
            .userdata_1 = fi.m_userdata1,
            .texture_format = @intToEnum(BasisTextureFormat, fi.m_tex_format),
            .y_flipped = fi.m_y_flipped,
            .is_etc1s = fi.m_etc1s,
            .has_alpha_slices = fi.m_has_alpha_slices,
        };
    } else {
        return error.Unknown;
    }
}

pub fn getImageLevelDescriptor(self: Transcoder, data: []const u8, image_index: u32, level_index: u32) error{Unknown}!ImageLevelDescriptor {
    var desc: ImageLevelDescriptor = undefined;
    return if (binding.transcoder_get_image_level_desc(
        self.handle,
        data.ptr,
        @intCast(u32, data.len),
        image_index,
        level_index,
        &desc.original_width,
        &desc.original_height,
        &desc.block_count,
    ))
        desc
    else
        error.Unknown;
}

pub fn getImageInfo(self: Transcoder, data: []const u8, image_index: u32) error{Unknown}!ImageInfo {
    var ii: binding.ImageInfo = undefined;
    return if (binding.transcoder_get_image_info(self.handle, data.ptr, @intCast(u32, data.len), &ii, image_index))
        ImageInfo{
            .image_index = ii.m_image_index,
            .total_levels = ii.m_total_levels,
            .original_width = ii.m_orig_width,
            .original_height = ii.m_orig_height,
            .width = ii.m_width,
            .height = ii.m_height,
            .num_blocks_x = ii.m_num_blocks_x,
            .num_blocks_y = ii.m_num_blocks_y,
            .total_blocks = ii.m_total_blocks,
            .first_slice_index = ii.m_first_slice_index,
            .alpha_flag = ii.m_alpha_flag,
            .iframe_flag = ii.m_iframe_flag,
        }
    else
        error.Unknown;
}

pub fn getImageLevelInfo(self: Transcoder, data: []const u8, image_index: u32, level_index: u32) error{Unknown}!ImageLevelInfo {
    var ii: binding.ImageLevelInfo = undefined;
    return if (binding.transcoder_get_image_level_info(self.handle, data.ptr, @intCast(u32, data.len), &ii, image_index, level_index))
        ImageLevelInfo{
            .image_index = ii.m_image_index,
            .level_index = ii.m_level_index,
            .original_width = ii.m_orig_width,
            .original_height = ii.m_orig_height,
            .width = ii.m_width,
            .height = ii.m_height,
            .num_blocks_x = ii.m_num_blocks_x,
            .num_blocks_y = ii.m_num_blocks_y,
            .total_blocks = ii.m_total_blocks,
            .first_slice_index = ii.m_first_slice_index,
            .rgb_file_offset = ii.m_rgb_file_ofs,
            .rgb_file_len = ii.m_rgb_file_len,
            .alpha_file_offset = ii.m_alpha_file_ofs,
            .alpha_file_len = ii.m_alpha_file_len,
            .alpha_flag = ii.m_alpha_flag,
            .iframe_flag = ii.m_iframe_flag,
        }
    else
        error.Unknown;
}

pub const BasisTextureType = enum(u3) {
    _2d = 0,
    _2d_array = 1,
    cubemap_array = 2,
    video_frames = 3,
    volume = 4,

    pub fn name(self: BasisTextureType) []const u8 {
        return std.mem.span(binding.basis_get_texture_type_name(@enumToInt(self)));
    }
};

pub const BasisTextureFormat = enum(u1) {
    etc1s = 0,
    uastc4x4 = 1,

    pub fn isEnabled(self: BasisTextureFormat, transcoder_format: TranscoderTextureFormat) bool {
        return binding.basis_is_format_supported(@enumToInt(self), @enumToInt(transcoder_format));
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

    pub fn hasAlpha(self: TranscoderTextureFormat) bool {
        return binding.basis_transcoder_format_has_alpha(@enumToInt(self));
    }

    pub fn isUncompressed(self: TranscoderTextureFormat) bool {
        return binding.basis_transcoder_format_is_uncompressed(@enumToInt(self));
    }

    pub fn bytesPerBlockOrPixel(self: TranscoderTextureFormat) u32 {
        return binding.basis_get_bytes_per_block_or_pixel(@enumToInt(self));
    }

    pub fn uncompressedBytesPerPixel(self: TranscoderTextureFormat) u32 {
        return binding.basis_get_uncompressed_bytes_per_pixel(@enumToInt(self));
    }

    pub fn blockWidth(self: TranscoderTextureFormat) u32 {
        return binding.basis_get_block_width(@enumToInt(self));
    }

    pub fn blockHeight(self: TranscoderTextureFormat) u32 {
        return binding.basis_get_block_height(@enumToInt(self));
    }

    pub fn name(self: TranscoderTextureFormat) []const u8 {
        return std.mem.span(binding.basis_get_format_name(@enumToInt(self)));
    }

    pub fn validateOutputBufferSize(
        self: TranscoderTextureFormat,
        output_blocks_buf_size_in_blocks_or_pixels: u32,
        original_width: u32,
        original_height: u32,
        total_slice_blocks: u32,
        output_row_pitch_in_blocks_or_pixels: ?u32,
        output_rows_in_pixels: ?u32,
    ) bool {
        return binding.basis_validate_output_buffer_size(
            @enumToInt(self),
            output_blocks_buf_size_in_blocks_or_pixels,
            original_width,
            original_height,
            output_row_pitch_in_blocks_or_pixels orelse 0,
            output_rows_in_pixels orelse 0,
            total_slice_blocks,
        );
    }

    pub fn minOutputBufSize(
        self: TranscoderTextureFormat,
        original_width: u32,
        original_height: u32,
        total_slice_blocks: u32,
        output_row_pitch_in_blocks_or_pixels: ?u32,
        output_rows_in_pixels: ?u32,
    ) u32 {
        const res = if (self.isUncompressed())
            (output_rows_in_pixels orelse original_height) * (output_row_pitch_in_blocks_or_pixels orelse original_width)
        else if (self == .fxt1_rgb)
            ((original_width + 7) / 8) * ((original_height + 3) / 4)
        else
            total_slice_blocks;

        std.debug.assert(self.validateOutputBufferSize(
            res,
            original_width,
            original_height,
            total_slice_blocks,
            output_row_pitch_in_blocks_or_pixels,
            output_rows_in_pixels,
        ));

        return res * self.bytesPerBlockOrPixel();
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

    pub fn name(self: TranscoderBlockFormat) []const u8 {
        return std.mem.span(binding.basis_get_block_format_name(@enumToInt(self)));
    }

    pub fn isUncompressed(self: TranscoderBlockFormat) bool {
        return binding.basis_block_format_is_uncompressed(@enumToInt(self));
    }
};

pub const ImageLevelDescriptor = struct {
    original_width: u32,
    original_height: u32,
    block_count: u32,
};

pub const ImageInfo = struct {
    image_index: u32,
    total_levels: u32,
    original_width: u32,
    original_height: u32,
    width: u32,
    height: u32,
    num_blocks_x: u32,
    num_blocks_y: u32,
    total_blocks: u32,
    first_slice_index: u32,
    alpha_flag: bool,
    iframe_flag: bool,
};

pub const ImageLevelInfo = struct {
    image_index: u32,
    level_index: u32,
    original_width: u32,
    original_height: u32,
    width: u32,
    height: u32,
    num_blocks_x: u32,
    num_blocks_y: u32,
    total_blocks: u32,
    first_slice_index: u32,
    rgb_file_offset: u32,
    rgb_file_len: u32,
    alpha_file_offset: u32,
    alpha_file_len: u32,
    alpha_flag: bool,
    iframe_flag: bool,
};

pub const FileInfo = struct {
    version: u32,
    total_header_size: u32,
    total_selectors: u32,
    selector_codebook_offset: u32,
    selector_codebook_size: u32,
    tables_offset: u32,
    tables_size: u32,
    slices_size: u32,
    texture_type: BasisTextureType,
    us_per_frame: u32,
    total_images: u32,
    userdata_0: u32,
    userdata_1: u32,
    texture_format: BasisTextureFormat,
    y_flipped: bool,
    is_etc1s: bool,
    has_alpha_slices: bool,
};

pub const TranscodeParams = struct {
    image_index: u32,
    level_index: u32,
    decode_flags: ?DecodeFlags,
    /// in blocks or pixels
    output_row_pitch: ?u32,
    /// in pixels
    output_rows: ?u32,
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
        var value = std.mem.zeroes(DecodeFlags);
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

const test_src_rgb = @import("basis_test_sources").src_rgb;

test "transcode" {
    const trnscdr = Transcoder.init();
    defer trnscdr.deinit();

    try testing.expect(trnscdr.validateFileChecksums(test_src_rgb, true));
    try testing.expect(trnscdr.validateHeader(test_src_rgb));
    _ = trnscdr.getTextureType(test_src_rgb);
    _ = try trnscdr.getUserData(test_src_rgb);
    _ = try trnscdr.getFileInfo(test_src_rgb);
    try std.testing.expectEqual(@as(u32, 1), trnscdr.getImageCount(test_src_rgb));
    try std.testing.expectEqual(@as(u32, 9), trnscdr.getImageLevelCount(test_src_rgb, 0));
    _ = try trnscdr.getImageLevelDescriptor(test_src_rgb, 0, 0);
    _ = try trnscdr.getImageInfo(test_src_rgb, 0);
    _ = try trnscdr.getImageLevelInfo(test_src_rgb, 0, 0);
}

test "enums/flags" {
    try testing.expectEqualStrings("2D", BasisTextureType._2d.name());
    try testing.expect(BasisTextureFormat.etc1s.isEnabled(.etc1_rgb));
}
