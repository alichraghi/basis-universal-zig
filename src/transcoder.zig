const std = @import("std");
const testing = std.testing;
pub const binding = @import("binding.zig");

var global_inited = false;

pub const TextureFormat = enum(u5) {
    etc1 = 0,
    etc1s = 1,
    etc2_rgb = 2,
    etc2_rgba = 3,
    etc2_alpha = 4,
    bc1 = 5,
    bc3 = 6,
    bc4 = 7,
    bc5 = 8,
    bc7 = 9,
    astc4x4 = 10,
    pvrtc1_4_rgb = 11,
    pvrtc1_4_rgba = 12,
    atc_rgb = 13,
    atc_rgba_interpolated_alpha = 14,
    fxt1_rgb = 15,
    pvrtc2_4_rgba = 16,
    etc2_r11_eac = 17,
    etc2_rg11_eac = 18,
    uastc4x4 = 19,
    bc1_nv = 20,
    bc1_amd = 21,
    rgba32 = 22,
    rgb565 = 23,
    bgr565 = 24,
    rgba4444 = 25,
    abgr4444 = 26,
};

pub const BlockFormat = enum(u5) {
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

pub const BasisTextureType = enum(u3) {
    _2d = 0,
    _2d_array = 1,
    cubemap_array = 2,
    video_frames = 3,
    volume = 4,
};

pub const BasisTextureFormat = enum(u1) {
    etc1s = 0,
    uastc4x4 = 1,
};

pub const TranscoderTextureFormat = enum(u5) {
    tfetc1_rgb = 0,
    tfetc2_rgba = 1,
    tfbc1_rgb = 2,
    tfbc3_rgba = 3,
    tfbc4_r = 4,
    tfbc5_rg = 5,
    tfbc7_rgba = 6,
    tfbc7_alt = 7,
    tfpvrtc1_4_rgb = 8,
    tfpvrtc1_4_rgba = 9,
    tfastc_4x4_rgba = 10,
    tfatc_rgb = 11,
    tfatc_rgba = 12,
    tfrgba32 = 13,
    tfrgb565 = 14,
    tfbgr565 = 15,
    tfrgba4444 = 16,
    tffxt1_rgb = 17,
    tfpvrtc2_4_rgb = 18,
    tfpvrtc2_4_rgba = 19,
    tfetc2_eac_r11 = 20,
    tfetc2_eac_rg11 = 21,
};

pub const ImageLevelDescription = struct {
    original_width: u32,
    original_height: u32,
    block_count: u32,
};

pub const ImageInfo = struct {
    index: u32,
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
        return bitFieldsToStruct(DecodeFlags, Flag, bits);
    }

    pub fn cast(self: DecodeFlags) u32 {
        return structToBitFields(u32, Flag, self);
    }
};

fn structToBitFields(comptime IntType: type, comptime EnumDataType: type, flags: anytype) IntType {
    var value: IntType = 0;
    inline for (comptime std.meta.fieldNames(EnumDataType)) |field_name| {
        if (@field(flags, field_name)) {
            value |= @enumToInt(@field(EnumDataType, field_name));
        }
    }
    return value;
}

fn bitFieldsToStruct(comptime StructType: type, comptime EnumDataType: type, flags: anytype) StructType {
    var value = std.mem.zeroes(StructType);
    inline for (comptime std.meta.fieldNames(EnumDataType)) |field_name| {
        if (flags & (@enumToInt(@field(EnumDataType, field_name))) != 0) {
            @field(value, field_name) = true;
        }
    }
    return value;
}

const Transcoder = @This();

handle: *binding.BasisuTranscoder,

pub fn init() Transcoder {
    if (!global_inited) {
        binding.basisu_transcoder_init();
        global_inited = true;
    }
    return .{ .handle = binding.transcoder_init() };
}

pub fn deinit(self: Transcoder) void {
    binding.transcoder_deinit(self.handle);
}

pub fn validateHeader(self: Transcoder, data: []const u8) bool {
    return binding.transcoder_validate_header(self.handle, @ptrCast(*const anyopaque, &data[0]), @intCast(u32, data.len));
}

pub fn getFileInfo(self: Transcoder, data: []const u8) error{ InvalidTextureFormat, Unknown }!FileInfo {
    var fi: binding.FileInfo = undefined;
    if (binding.transcoder_get_file_info(self.handle, @ptrCast(*const anyopaque, &data[0]), @intCast(u32, data.len), &fi)) {
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

pub fn getImageInfo(self: Transcoder, data: []const u8, index: u32) error{Unknown}!ImageInfo {
    var ii: binding.ImageInfo = undefined;
    if (binding.transcoder_get_image_info(self.handle, @ptrCast(*const anyopaque, &data[0]), @intCast(u32, data.len), &ii, index)) {
        return ImageInfo{
            .index = ii.m_image_index,
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
        };
    } else {
        return error.Unknown;
    }
}

const test_src_rgb = @import("basis_test_sources").src_rgb;

test "read info" {
    const trnscdr = Transcoder.init();
    defer trnscdr.deinit();

    try testing.expect(trnscdr.validateHeader(test_src_rgb));
    _ = try trnscdr.getFileInfo(test_src_rgb);
    _ = try trnscdr.getImageInfo(test_src_rgb, 0);
}
