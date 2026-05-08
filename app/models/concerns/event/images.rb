module Event::Images
  extend ActiveSupport::Concern

  included do
    has_one_attached :image
    attr_accessor :remove_image

    validate :acceptable_image
  end

  def display_image
    return remote_poster_url if remote_poster_url.present?
    return image if image.attached?

    "https://placehold.co/600x350/e2e8f0/0f172a?text=#{title.truncate(20)}"
  end

  private

  def acceptable_image
    return unless image.attached?

    if image.blob.byte_size > Event::MAX_IMAGE_SIZE
      errors.add(:image, I18n.t("errors.messages.image_too_large"))
    end

    return if Event::ACCEPTABLE_IMAGE_TYPES.include?(image.blob.content_type.to_s)

    errors.add(:image, I18n.t("errors.messages.image_invalid_type"))
  end
end
