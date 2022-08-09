const std = @import("std");
const testing = std.testing;

pub const FileInfo = extern struct {
    m_version: u32,
    m_total_header_size: u32,
    m_total_selectors: u32,
    m_selector_codebook_ofs: u32,
    m_selector_codebook_size: u32,
    m_total_endpoints: u32,
    m_endpoint_codebook_ofs: u32,
    m_endpoint_codebook_size: u32,
    m_tables_ofs: u32,
    m_tables_size: u32,
    m_slices_size: u32,
    m_tex_type: BasisTextureType,
    m_us_per_frame: u32,
    m_total_images: u32,
    m_userdata0: u32,
    m_userdata1: u32,
    m_tex_format: BasisTextureFormat,
    m_y_flipped: bool,
    m_etc1s: bool,
    m_has_alpha_slices: bool,
};

pub const ImageInfo = extern struct {
    m_image_index: u32,
    m_total_levels: u32,
    m_orig_width: u32,
    m_orig_height: u32,
    m_width: u32,
    m_height: u32,
    m_num_blocks_x: u32,
    m_num_blocks_y: u32,
    m_total_blocks: u32,
    m_first_slice_index: u32,
    m_alpha_flag: bool,
    m_iframe_flag: bool,
};

pub const ImageLevelInfo = extern struct {
    m_image_index: u32,
    m_level_index: u32,
    m_orig_width: u32,
    m_orig_height: u32,
    m_width: u32,
    m_height: u32,
    m_num_blocks_x: u32,
    m_num_blocks_y: u32,
    m_total_blocks: u32,
    m_first_slice_index: u32,
    m_rgb_file_ofs: u32,
    m_rgb_file_len: u32,
    m_alpha_file_ofs: u32,
    m_alpha_file_len: u32,
    m_alpha_flag: bool,
    m_iframe_flag: bool,
};

pub const BasisuTranscoderStateBlockPreds = extern struct {
    m_endpoint_index: u16,
    m_pred_bits: u8,
};

pub const BasisuTranscoder = opaque {};
pub const BasisuTranscoderState = opaque {};
pub const BasisuLowlevelUASTCTranscoder = opaque {};

pub const TranscoderTextureFormat = c_int;
pub const BlockFormat = c_int;
pub const BasisTextureType = c_int;
pub const BasisTextureFormat = c_int;
pub const BasisuDecodeFlags = u32;

pub extern fn basis_get_bytes_per_block_or_pixel(TranscoderTextureFormat) u32;
pub extern fn basis_get_format_name(TranscoderTextureFormat) [*]const u8;
pub extern fn basis_get_block_format_name(BlockFormat) [*]const u8;
pub extern fn basis_transcoder_format_has_alpha(TranscoderTextureFormat) bool;
pub extern fn basis_get_basisu_texture_format(TranscoderTextureFormat) c_int;
pub extern fn basis_get_texture_type_name(BasisTextureType) [*]const u8;
pub extern fn basis_transcoder_format_is_uncompressed(TranscoderTextureFormat) bool;
pub extern fn basis_block_format_is_uncompressed(BlockFormat) bool;
pub extern fn basis_get_uncompressed_bytes_per_pixel(TranscoderTextureFormat) u32;
pub extern fn basis_get_block_width(TranscoderTextureFormat) u32;
pub extern fn basis_get_block_height(TranscoderTextureFormat) u32;
pub extern fn basis_is_format_supported(TranscoderTextureFormat, BasisTextureFormat) bool;
pub extern fn basis_validate_output_buffer_size(
    target_format: TranscoderTextureFormat,
    output_blocks_buf_size_in_blocks_or_pixels: u32,
    orig_width: u32,
    orig_height: u32,
    output_row_pitch_in_blocks_or_pixels: u32,
    output_rows_in_pixels: u32,
    total_slice_blocks: u32,
) bool;
pub extern fn low_level_uastc_transcoder_init() *BasisuLowlevelUASTCTranscoder;
pub extern fn low_level_uastc_transcoder_deinit(*BasisuLowlevelUASTCTranscoder) void;
pub extern fn low_level_uastc_transcoder_transcode_slice(
    *BasisuLowlevelUASTCTranscoder,
    p_dst_blocks: *anyopaque, // TODO
    num_blocks_x: u32,
    num_blocks_y: u32,
    p_image_data: [*]const u8, // TODO
    image_data_size: u32,
    format: c_int,
    output_block_or_pixel_stride_in_bytes: u32,
    bc1_allow_threecolor_blocks: bool,
    has_alpha: bool,
    orig_width: u32,
    orig_height: u32,
    output_row_pitch_in_blocks_or_pixels: u32,
    p_state: *BasisuTranscoderState,
    output_rows_in_pixels: u32,
    channel0: c_int,
    channel1: c_int,
    decode_flags: u32,
) bool;
pub extern fn transcoder_init() *BasisuTranscoder;
pub extern fn transcoder_deinit(*BasisuTranscoder) void;
pub extern fn transcoder_validate_file_checksums(*const BasisuTranscoder, *const anyopaque, u32, full_validation: bool) bool;
pub extern fn transcoder_validate_header(*const BasisuTranscoder, *const anyopaque, u32) bool;
pub extern fn transcoder_get_texture_type(*const BasisuTranscoder, *const anyopaque, u32) BasisTextureType;
pub extern fn transcoder_get_userdata(*const BasisuTranscoder, *const anyopaque, u32, userdata0: *u32, userdata1: *u32) bool;
pub extern fn transcoder_get_total_images(*const BasisuTranscoder, *const anyopaque, u32) u32;
pub extern fn transcoder_get_tex_format(*const BasisuTranscoder, *const anyopaque, u32) BasisTextureFormat;
pub extern fn transcoder_get_total_image_levels(*const BasisuTranscoder, *const anyopaque, u32, index: u32) u32;
pub extern fn transcoder_get_image_level_desc(
    *const BasisuTranscoder,
    *const anyopaque,
    u32,
    image_index: u32,
    level_index: u32,
    orig_width: *u32,
    orig_height: *u32,
    total_blocks: *u32,
) bool;
pub extern fn transcoder_get_image_info(*const BasisuTranscoder, *const anyopaque, u32, image_info: *ImageInfo, image_index: u32) bool;
pub extern fn transcoder_get_image_level_info(
    *const BasisuTranscoder,
    *const anyopaque,
    u32,
    level_info: *ImageLevelInfo,
    image_index: u32,
    level_index: u32,
) bool;
pub extern fn transcoder_get_file_info(*const BasisuTranscoder, *const anyopaque, u32, *FileInfo) bool;
pub extern fn transcoder_start_transcoding(*const BasisuTranscoder, *const anyopaque, u32) bool;
pub extern fn transcoder_stop_transcoding(*const BasisuTranscoder) bool;
pub extern fn transcoder_get_ready_to_transcode(*const BasisuTranscoder) bool;
pub extern fn transcoder_transcode_image_level(
    *const BasisuTranscoder,
    *const anyopaque,
    u32,
    image_index: u32,
    level_index: u32,
    p_output_blocks: *anyopaque,
    output_blocks_buf_size_in_blocks_or_pixels: u32,
    format: TranscoderTextureFormat,
    decode_flags: BasisuDecodeFlags,
    output_row_pitch_in_blocks_or_pixels: u32,
    p_state: *BasisuTranscoderState,
    output_rows_in_pixels: u32,
) bool;
pub extern fn basisu_transcoder_init() void;

test "verify types size/align" {
    try testing.expectEqual(44, @sizeOf(ImageInfo));
    try testing.expectEqual(4, @alignOf(ImageInfo));

    try testing.expectEqual(60, @sizeOf(ImageLevelInfo));
    try testing.expectEqual(4, @alignOf(ImageLevelInfo));

    try testing.expectEqual(4, @sizeOf(BasisuTranscoderStateBlockPreds));
    try testing.expectEqual(2, @alignOf(BasisuTranscoderStateBlockPreds));

    try testing.expectEqual(4, @alignOf(FileInfo));
}
