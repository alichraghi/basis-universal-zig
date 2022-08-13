#include <basisu_transcoder.h>
#include <cstdbool>
#include <cstdint>

extern "C" {
void basis_init();

bool basis_is_format_supported(uint32_t tex_type, uint32_t fmt);

void *basis_open(void *src, uint32_t src_size);
void basis_close(void *h);

uint32_t basis_get_images_count(void *h);
uint32_t basis_get_levels_count(void *h, uint32_t image_index);

bool basis_get_image_level_desc(void *h, uint32_t image_index,
                                uint32_t level_index, uint32_t &orig_width,
                                uint32_t &orig_height, uint32_t &block_count);

bool basis_get_image_transcoded_size(void *h, uint32_t image_index,
                                     uint32_t level_index, uint32_t format,
                                     uint32_t &size);

bool basis_start_transcoding(void *h);
bool basis_stop_transcoding(void *h);

bool basis_transcode_image(void *h, void *out, uint32_t out_size,
                           uint32_t image_index, uint32_t level_index,
                           uint32_t format, uint32_t decode_flags,
                           uint32_t output_row_pitch_in_blocks_or_pixels,
                           uint32_t output_rows_in_pixels);
}

void basis_init() { basist::basisu_transcoder_init(); }

#define MAGIC 0xDEADBEE1

struct basis_file {
  int m_magic;
  basist::basisu_transcoder m_transcoder;
  void *m_pFile;
  uint32_t m_file_size;

  basis_file() : m_transcoder() {}
};

// !null - success
// null - validation failure
void *basis_open(void *src, uint32_t src_size) {
  basis_file *f = new basis_file;
  f->m_pFile = src;
  f->m_file_size = src_size;

  if (!f->m_transcoder.validate_header(f->m_pFile, f->m_file_size)) {
    delete f;
    return nullptr;
  }
  f->m_magic = MAGIC;

  return f;
}

void basis_close(void *h) {
  basis_file *f = static_cast<basis_file *>(h);
  delete f;
}

uint32_t basis_get_images_count(void *h) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  return f->m_transcoder.get_total_images(f->m_pFile, f->m_file_size);
}

uint32_t basis_get_levels_count(void *h, uint32_t image_index) {
  basis_file *f = static_cast<basis_file *>(h);
  return f->m_transcoder.get_total_image_levels(f->m_pFile, f->m_file_size,
                                                image_index);
}

// transcoder_texture_format, basis_tex_format
bool basis_is_format_supported(uint32_t tex_type, uint32_t fmt) {
  return basist::basis_is_format_supported(
      (basist::transcoder_texture_format)tex_type,
      (basist::basis_tex_format)fmt);
}

// true - success
// false - OutOfBoundsLevelIndex
bool basis_get_image_level_desc(void *h, uint32_t image_index,
                                uint32_t level_index, uint32_t &orig_width,
                                uint32_t &orig_height, uint32_t &block_count) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  return f->m_transcoder.get_image_level_desc(
      f->m_pFile, f->m_file_size, image_index, level_index, orig_width,
      orig_height, block_count);
}

// true - success
// false - OutOfBoundsLevelIndex
bool basis_get_image_transcoded_size(void *h, uint32_t image_index,
                                     uint32_t level_index, uint32_t format,
                                     uint32_t &size) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  uint32_t orig_width, orig_height, total_blocks;
  if (!f->m_transcoder.get_image_level_desc(
          f->m_pFile, f->m_file_size, image_index, level_index, orig_width,
          orig_height, total_blocks))
    return false;

  uint32_t bytes_per_block_or_pixel = basis_get_bytes_per_block_or_pixel(
      (basist::transcoder_texture_format)format);
  if (basis_transcoder_format_is_uncompressed(
          (basist::transcoder_texture_format)format)) {
    size = orig_width * orig_height * bytes_per_block_or_pixel;
  } else {
    size = total_blocks * bytes_per_block_or_pixel;
  }

  return true;
}

// true - success
// false - unknown
bool basis_start_transcoding(void *h) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  return f->m_transcoder.start_transcoding(f->m_pFile, f->m_file_size);
}

// true - success
// false - unknown
bool basis_stop_transcoding(void *h) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  return f->m_transcoder.stop_transcoding();
}

// true - success
// false - unknown
bool basis_transcode_image(void *h, void *out, uint32_t out_size,
                           uint32_t image_index, uint32_t level_index,
                           uint32_t format, uint32_t decode_flags,
                           uint32_t output_row_pitch_in_blocks_or_pixels,
                           uint32_t output_rows_in_pixels) {
  basis_file *f = static_cast<basis_file *>(h);

  if (f->m_magic != MAGIC) // TODO: Remove
    exit(1);

  uint32_t bytes_per_block = basis_get_bytes_per_block_or_pixel(
      (basist::transcoder_texture_format)format);

  return f->m_transcoder.transcode_image_level(
      f->m_pFile, f->m_file_size, image_index, level_index, out,
      out_size / bytes_per_block, (basist::transcoder_texture_format)format,
      decode_flags, output_row_pitch_in_blocks_or_pixels, nullptr,
      output_rows_in_pixels);
}
