require "cgi"

module EtkinlikIo
  module TextCleaner
    BLOCK_TAG_PATTERN = %r{</?(p|div|section|article|header|footer|li|ul|ol|h[1-6])\b[^>]*>}i

    module_function

    def plain_text(value, preserve_paragraphs: false)
      text = CGI.unescapeHTML(value.to_s.gsub(/&nbsp;/i, " "))
      text = text.tr("\u00A0", " ")
      text = text.gsub(%r{<script\b[^>]*>.*?</script>}im, "")
      text = text.gsub(%r{<style\b[^>]*>.*?</style>}im, "")

      if preserve_paragraphs
        text = text.gsub(%r{<br\s*/?>}i, "\n")
        text = text.gsub(BLOCK_TAG_PATTERN, "\n\n")
      end

      text = ActionView::Base.full_sanitizer.sanitize(text)
      text = CGI.unescapeHTML(text)

      preserve_paragraphs ? normalize_paragraphs(text) : text.squish
    end

    def normalize_paragraphs(text)
      text.to_s
          .lines
          .map(&:squish)
          .join("\n")
          .gsub(/\n{3,}/, "\n\n")
          .strip
    end
  end
end
