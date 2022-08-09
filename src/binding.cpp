#include <basisu_transcoder.h>
#include <stdint.h>

#include <iostream>

extern "C" {
struct basisu_file_info {
  void reset(basist::basisu_file_info file_info) {
    m_version = file_info.m_version;
    m_total_header_size = file_info.m_total_header_size;

    m_total_selectors = file_info.m_total_selectors;
    m_selector_codebook_ofs = file_info.m_selector_codebook_ofs;
    m_selector_codebook_size = file_info.m_selector_codebook_size;

    m_total_endpoints = file_info.m_total_endpoints;
    m_endpoint_codebook_ofs = file_info.m_endpoint_codebook_ofs;
    m_endpoint_codebook_size = file_info.m_endpoint_codebook_size;

    m_tables_ofs = file_info.m_tables_ofs;
    m_tables_size = file_info.m_tables_size;

    m_slices_size = file_info.m_slices_size;

    m_tex_type = file_info.m_tex_type;
    m_us_per_frame = file_info.m_us_per_frame;

    m_total_images = file_info.m_total_images;

    m_userdata0 = file_info.m_userdata0;
    m_userdata1 = file_info.m_userdata1;

    m_tex_format = file_info.m_tex_format;

    m_y_flipped = file_info.m_y_flipped;
    m_etc1s = file_info.m_etc1s;
    m_has_alpha_slices = file_info.m_has_alpha_slices;
  }

  uint32_t m_version;
  uint32_t m_total_header_size;

  uint32_t m_total_selectors;
  uint32_t m_selector_codebook_ofs;
  uint32_t m_selector_codebook_size;

  uint32_t m_total_endpoints;
  uint32_t m_endpoint_codebook_ofs;
  uint32_t m_endpoint_codebook_size;

  uint32_t m_tables_ofs;
  uint32_t m_tables_size;

  uint32_t m_slices_size;

  basist::basis_texture_type m_tex_type;
  uint32_t m_us_per_frame;

  // Low-level slice information (1 slice per image for color-only basis files,
  // 2 for alpha basis files)
  // basist::basisu_slice_info_vec m_slice_info;

  uint32_t m_total_images; // total # of images
  // std::vector<uint32_t> m_image_mipmap_levels; // the # of mipmap levels for
  // each image

  uint32_t m_userdata0;
  uint32_t m_userdata1;

  basist::basis_tex_format m_tex_format; // ETC1S, UASTC, etc.

  bool m_y_flipped;        // true if the image was Y flipped
  bool m_etc1s;            // true if the file is ETC1S
  bool m_has_alpha_slices; // true if the texture has alpha slices (for ETC1S:
                           // even slices RGB, odd slices alpha)
};

uint32_t
basis_get_bytes_per_block_or_pixel(basist::transcoder_texture_format fmt) {
  return basist::basis_get_bytes_per_block_or_pixel(fmt);
}

const char *basis_get_format_name(basist::transcoder_texture_format fmt) {
  return basist::basis_get_format_name(fmt);
}

const char *basis_get_block_format_name(basist::block_format fmt) {
  return basist::basis_get_block_format_name(fmt);
}

bool basis_transcoder_format_has_alpha(basist::transcoder_texture_format fmt) {
  return basist::basis_transcoder_format_has_alpha(fmt);
}

basisu::texture_format
basis_get_basisu_texture_format(basist::transcoder_texture_format fmt) {
  return basist::basis_get_basisu_texture_format(fmt);
}

const char *basis_get_texture_type_name(basist::basis_texture_type tex_type) {
  return basist::basis_get_texture_type_name(tex_type);
}

bool basis_transcoder_format_is_uncompressed(
    basist::transcoder_texture_format tex_type) {
  return basist::basis_transcoder_format_is_uncompressed(tex_type);
}

bool basis_block_format_is_uncompressed(basist::block_format fmt) {
  return basist::basis_block_format_is_uncompressed(fmt);
}

uint32_t
basis_get_uncompressed_bytes_per_pixel(basist::transcoder_texture_format fmt) {
  return basist::basis_get_uncompressed_bytes_per_pixel(fmt);
}

uint32_t basis_get_block_width(basist::transcoder_texture_format tex_type) {
  return basist::basis_get_block_width(tex_type);
}

uint32_t basis_get_block_height(basist::transcoder_texture_format tex_type) {
  return basist::basis_get_block_height(tex_type);
}

bool basis_is_format_supported(basist::transcoder_texture_format tex_type,
                               basist::basis_tex_format fmt) {
  return basist::basis_is_format_supported(tex_type, fmt);
}

bool basis_validate_output_buffer_size(
    basist::transcoder_texture_format target_format,
    uint32_t output_blocks_buf_size_in_blocks_or_pixels, uint32_t orig_width,
    uint32_t orig_height, uint32_t output_row_pitch_in_blocks_or_pixels,
    uint32_t output_rows_in_pixels, uint32_t total_slice_blocks) {
  return basist::basis_validate_output_buffer_size(
      target_format, output_blocks_buf_size_in_blocks_or_pixels, orig_width,
      orig_height, output_row_pitch_in_blocks_or_pixels, output_rows_in_pixels,
      total_slice_blocks);
}

basist::basisu_lowlevel_uastc_transcoder *low_level_uastc_transcoder_init() {
  basist::basisu_lowlevel_uastc_transcoder *transcoder =
      new basist::basisu_lowlevel_uastc_transcoder;
  return transcoder;
}

void low_level_uastc_transcoder_deinit(
    basist::basisu_lowlevel_uastc_transcoder *transcoder) {
  delete transcoder;
}

bool low_level_uastc_transcoder_transcode_slice(
    basist::basisu_lowlevel_uastc_transcoder *transcoder, void *pDst_blocks,
    uint32_t num_blocks_x, uint32_t num_blocks_y, const uint8_t *pImage_data,
    uint32_t image_data_size, basist::block_format fmt,
    uint32_t output_block_or_pixel_stride_in_bytes,
    bool bc1_allow_threecolor_blocks, bool has_alpha, const uint32_t orig_width,
    const uint32_t orig_height, uint32_t output_row_pitch_in_blocks_or_pixels,
    basist::basisu_transcoder_state *pState, uint32_t output_rows_in_pixels,
    int channel0, int channel1, uint32_t decode_flags) {
  return transcoder->transcode_slice(
      pDst_blocks, num_blocks_x, num_blocks_y, pImage_data, image_data_size,
      fmt, output_block_or_pixel_stride_in_bytes, bc1_allow_threecolor_blocks,
      has_alpha, orig_width, orig_height, output_row_pitch_in_blocks_or_pixels,
      pState, output_rows_in_pixels, channel0, channel1, decode_flags);
}

//
// basisu_transcoder
//

basist::basisu_transcoder *transcoder_init() {
  basist::basisu_transcoder *transcoder = new basist::basisu_transcoder;
  return transcoder;
};

void transcoder_deinit(basist::basisu_transcoder *transcoder) {
  delete transcoder;
}

bool transcoder_validate_file_checksums(
    const basist::basisu_transcoder *transcoder, const void *pData,
    uint32_t data_size, bool full_validation) {
  return transcoder->validate_file_checksums(pData, data_size, full_validation);
}

bool transcoder_validate_header(const basist::basisu_transcoder *transcoder,
                                const void *pData, uint32_t data_size) {
  return transcoder->validate_header(pData, data_size);
}

basist::basis_texture_type
transcoder_get_texture_type(const basist::basisu_transcoder *transcoder,
                            const void *pData, uint32_t data_size) {
  return transcoder->get_texture_type(pData, data_size);
}

bool transcoder_get_userdata(const basist::basisu_transcoder *transcoder,
                             const void *pData, uint32_t data_size,
                             uint32_t &userdata0, uint32_t &userdata1) {
  return transcoder->get_userdata(pData, data_size, userdata0, userdata1);
}

int32_t transcoder_get_total_images(const basist::basisu_transcoder *transcoder,
                                    const void *pData, uint32_t data_size) {
  return transcoder->get_total_images(pData, data_size);
}

basist::basis_tex_format
transcoder_get_tex_format(const basist::basisu_transcoder *transcoder,
                          const void *pData, uint32_t data_size) {
  return transcoder->get_tex_format(pData, data_size);
}

uint32_t
transcoder_get_total_image_levels(const basist::basisu_transcoder *transcoder,
                                  const void *pData, uint32_t data_size,
                                  uint32_t image_index) {
  return transcoder->get_total_image_levels(pData, data_size, image_index);
}

bool transcoder_get_image_level_desc(
    const basist::basisu_transcoder *transcoder, const void *pData,
    uint32_t data_size, uint32_t image_index, uint32_t level_index,
    uint32_t &orig_width, uint32_t &orig_height, uint32_t &total_blocks) {
  return transcoder->get_image_level_desc(pData, data_size, image_index,
                                          level_index, orig_width, orig_height,
                                          total_blocks);
}

bool transcoder_get_image_info(const basist::basisu_transcoder *transcoder,
                               const void *pData, uint32_t data_size,
                               basist::basisu_image_info &image_info,
                               uint32_t image_index) {
  return transcoder->get_image_info(pData, data_size, image_info, image_index);
}

bool transcoder_get_image_level_info(
    const basist::basisu_transcoder *transcoder, const void *pData,
    uint32_t data_size, basist::basisu_image_level_info &level_info,
    uint32_t image_index, uint32_t level_index) {
  return transcoder->get_image_level_info(pData, data_size, level_info,
                                          image_index, level_index);
}

bool transcoder_get_file_info(basist::basisu_transcoder *transcoder,
                              const void *pData, uint32_t data_size,
                              basisu_file_info &file_info) {
  basist::basisu_file_info fi;
  if (!transcoder->get_file_info(pData, data_size, fi)) {
    return false;
  }

  file_info.reset(fi);
  return true;
}

bool transcoder_start_transcoding(basist::basisu_transcoder *transcoder,
                                  const void *pData, uint32_t data_size) {
  return transcoder->start_transcoding(pData, data_size);
}

bool transcoder_stop_transcoding(basist::basisu_transcoder *transcoder) {
  return transcoder->stop_transcoding();
}

bool transcoder_get_ready_to_transcode(
    const basist::basisu_transcoder *transcoder) {
  return transcoder->get_ready_to_transcode();
}

bool transcoder_transcode_image_level(
    basist::basisu_transcoder *transcoder, const void *pData,
    uint32_t data_size, uint32_t image_index, uint32_t level_index,
    void *pOutput_blocks, uint32_t output_blocks_buf_size_in_blocks_or_pixels,
    basist::transcoder_texture_format fmt,
    basist::basisu_decode_flags decode_flags,      // default: 0
    uint32_t output_row_pitch_in_blocks_or_pixels, // default: 0
    basist::basisu_transcoder_state *pState,       // default: nullptr
    uint32_t output_rows_in_pixels                 // default: 0
) {
  return transcoder->transcode_image_level(
      pData, data_size, image_index, level_index, pOutput_blocks,
      output_blocks_buf_size_in_blocks_or_pixels, fmt, decode_flags,
      output_row_pitch_in_blocks_or_pixels, pState, output_rows_in_pixels);
}

//
// Global functions
//

void basisu_transcoder_init() { basist::basisu_transcoder_init(); }

basist::debug_flags_t get_debug_flags() {
  return (basist::debug_flags_t)basist::get_debug_flags();
}

void set_debug_flags(basist::debug_flags_t f) { basist::set_debug_flags(f); }
}
