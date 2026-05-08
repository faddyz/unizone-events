module Events
  module ImageHelper
    EVENT_IMAGE_DIMENSIONS = Event::IMAGE_VARIANT_DIMENSIONS
    EVENT_IMAGE_PROXY_EXPIRES_IN = nil
    EVENT_IMAGE_PLACEHOLDER_SRC = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="

    def event_has_poster?(event)
      event.remote_poster_url.present? || event.image.attached?
    end

    def event_image_options(variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil)
      width, height = EVENT_IMAGE_DIMENSIONS.fetch(variant)
      {
        alt: alt,
        class: class_name.presence,
        loading: loading,
        decoding: "async",
        width: width,
        height: height,
        sizes: sizes || "#{width}px",
        fetchpriority: fetchpriority,
        data: data,
        aria: aria
      }.compact
    end

    def event_image_tag(event, variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil, defer_src: false)
      return unless event.image.attached?

      source = event_image_source(event.image, variant)
      data_options = event_image_data(event.image, data)
      data_options = event_deferred_image_data(data_options, source) if defer_src

      image_tag(
        defer_src ? EVENT_IMAGE_PLACEHOLDER_SRC : source,
        event_image_options(
          variant,
          alt: alt,
          class_name: class_name,
          loading: loading,
          sizes: sizes,
          fetchpriority: fetchpriority,
          data: data_options,
          aria: aria
        )
      )
    end

    def event_poster_image_tag(event, variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil, defer_src: false)
      if event.remote_poster_url.present?
        options = event_image_options(
          variant,
          alt: alt,
          class_name: class_name,
          loading: loading,
          sizes: sizes,
          fetchpriority: fetchpriority,
          data: defer_src ? event_deferred_image_data(data || {}, event.remote_poster_url) : data,
          aria: aria
        )

        return image_tag(defer_src ? EVENT_IMAGE_PLACEHOLDER_SRC : event.remote_poster_url, options)
      end

      event_image_tag(
        event,
        variant,
        alt: alt,
        class_name: class_name,
        loading: loading,
        sizes: sizes,
        fetchpriority: fetchpriority,
        data: data,
        aria: aria,
        defer_src: defer_src
      )
    end

    def event_card_image_sizes(featured: false, compact: false)
      if featured
        "(min-width: 1024px) 34rem, 88vw"
      elsif compact
        "(min-width: 1024px) 16rem, 88vw"
      else
        "(min-width: 1280px) 25vw, (min-width: 640px) 50vw, 92vw"
      end
    end

  private

    def event_image_source(image, variant)
      return rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN) unless image.variable?

      representation = image.variant(Event::IMAGE_VARIANTS.fetch(variant))

      rails_storage_proxy_path(
        representation,
        expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN
      )
    rescue StandardError => error
      Rails.logger.warn("Falling back to original event image after variant URL failure: #{error.class}: #{error.message}")
      rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN)
    end

    def event_image_data(image, data)
      merged = (data || {}).dup
      merged[:controller] = [ merged[:controller], "image-fallback" ].compact_blank.join(" ")
      merged[:action] = [ merged[:action], "error->image-fallback#recover" ].compact_blank.join(" ")
      merged[:image_fallback_src_value] = rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN)
      merged
    end

    def event_deferred_image_data(data, source)
      data = data.dup
      data[:poster_lightbox_target] = [ data[:poster_lightbox_target], "image" ].compact_blank.join(" ")
      data[:poster_lightbox_src] = source
      data
    end

  end
end
