pub const Compressor = opaque {};
pub const CompressorParams = opaque {};
pub const Image = opaque {};

pub const CompressorBasisFile = extern struct {
    pData: [*]const u8,
    length: usize,
};

pub extern fn basisu_encoder_init() void;

pub extern fn compressor_params_init() *CompressorParams;
pub extern fn compressor_params_deinit(*CompressorParams) void;
pub extern fn compressor_params_clear(*CompressorParams) void;
pub extern fn compressor_params_set_quality_level(*CompressorParams, c_int) void;
pub extern fn compressor_params_get_pack_uastc_flags(*CompressorParams) u32;
pub extern fn compressor_params_set_pack_uastc_flags(*CompressorParams, u32) void;
pub extern fn compressor_params_set_uastc(*CompressorParams, bool) void;
pub extern fn compressor_params_set_perceptual(*CompressorParams, bool) void;
pub extern fn compressor_params_set_mip_srgb(*CompressorParams, bool) void;
pub extern fn compressor_params_set_no_selector_rdo(*CompressorParams, bool) void;
pub extern fn compressor_params_set_no_endpoint_rdo(*CompressorParams, bool) void;
pub extern fn compressor_params_set_rdo_uastc(*CompressorParams, bool) void;
pub extern fn compressor_params_set_rdo_uastc_quality_scalar(*CompressorParams, f32) void;
pub extern fn compressor_params_set_generate_mipmaps(*CompressorParams, bool) void;
pub extern fn compressor_params_set_mip_smallest_dimension(*CompressorParams, c_int) void;
pub extern fn compressor_params_get_or_create_source_image(*CompressorParams, u8) *Image;
pub extern fn compressor_params_resize_source_image_list(*CompressorParams, usize) void;
pub extern fn compressor_params_clear_source_image_list(*CompressorParams) void;

pub extern fn compressor_new() *Compressor;
pub extern fn compressor_delete(*Compressor) void;
pub extern fn compressor_init(*Compressor, *CompressorParams) bool;
pub extern fn compressor_process(*Compressor) u4;

pub extern fn compressor_get_output_basis_file(*Compressor) CompressorBasisFile;
pub extern fn compressor_get_basis_file_size(*Compressor) u32;
pub extern fn compressor_get_basis_bits_per_texel(*Compressor) f64;
pub extern fn compressor_get_any_source_image_has_alpha(*Compressor) bool;
