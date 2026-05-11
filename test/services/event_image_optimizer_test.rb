require "test_helper"
require "vips"

class EventImageOptimizerTest < ActiveSupport::TestCase
  test "converts uploaded posters to optimized jpeg" do
    upload = image_upload(width: 2_400, height: 1_200, extension: "png", content_type: "image/png")

    optimized = EventImageOptimizer.optimize(upload)
    image = Vips::Image.new_from_file(optimized.fetch(:io).path)

    assert_equal "image/jpeg", optimized.fetch(:content_type)
    assert_equal "large-poster.jpg", optimized.fetch(:filename)
    assert_operator image.width, :<=, EventImageOptimizer::MAX_DIMENSION
    assert_operator image.height, :<=, EventImageOptimizer::MAX_DIMENSION
    assert_operator optimized.fetch(:io).size, :<, upload.tempfile.size
  ensure
    optimized&.fetch(:io, nil)&.close!
    upload&.tempfile&.close!
  end

  test "returns original upload when image cannot be processed" do
    file = Tempfile.new([ "broken-poster", ".png" ])
    file.binmode
    file.write("not an image")
    file.rewind
    upload = Rack::Test::UploadedFile.new(file.path, "image/png", true, original_filename: "broken.png")

    assert_same upload, EventImageOptimizer.optimize(upload)
  ensure
    file&.close!
  end

  private

  def image_upload(width:, height:, extension:, content_type:)
    file = Tempfile.new([ "large-poster", ".#{extension}" ])
    file.binmode

    image = Vips::Image.black(width, height).new_from_image([ 255, 77, 61 ]).cast(:uchar)
    image.write_to_file(file.path)
    file.rewind

    Rack::Test::UploadedFile.new(file.path, content_type, true, original_filename: "Large Poster.#{extension}")
  end
end
