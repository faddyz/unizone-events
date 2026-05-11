require "image_processing/vips"

class EventImageOptimizer
  MAX_DIMENSION = 1_600
  JPEG_QUALITY = 82
  OUTPUT_CONTENT_TYPE = "image/jpeg"
  OPTIMIZABLE_CONTENT_TYPES = %w[
    image/jpeg
    image/jpg
    image/png
    image/webp
  ].freeze

  def self.optimize(upload)
    new(upload).optimize
  end

  def initialize(upload)
    @upload = upload
  end

  def optimize
    return upload unless optimizable?

    tempfile = Tempfile.new([ optimized_basename, ".jpg" ])
    tempfile.binmode

    ImageProcessing::Vips
      .source(upload_source)
      .resize_to_limit(MAX_DIMENSION, MAX_DIMENSION)
      .convert("jpg")
      .saver(strip: true, quality: JPEG_QUALITY, interlace: true)
      .call(destination: tempfile.path)

    tempfile.rewind
    {
      io: tempfile,
      filename: "#{optimized_basename}.jpg",
      content_type: OUTPUT_CONTENT_TYPE
    }
  rescue StandardError => error
    Rails.logger.warn("Event image optimization skipped: #{error.class}: #{error.message}")
    upload
  end

  private

  attr_reader :upload

  def optimizable?
    OPTIMIZABLE_CONTENT_TYPES.include?(upload_content_type)
  end

  def upload_content_type
    upload.respond_to?(:content_type) ? upload.content_type.to_s.downcase : ""
  end

  def upload_source
    return upload.tempfile if upload.respond_to?(:tempfile)
    return upload.to_io if upload.respond_to?(:to_io)

    upload
  end

  def optimized_basename
    base = if upload.respond_to?(:original_filename)
      File.basename(upload.original_filename.to_s, ".*")
    else
      "event-poster"
    end

    base.parameterize.presence || "event-poster"
  end
end
