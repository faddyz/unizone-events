module EtkinlikIo
  module Catalog
    SOURCE = ExternalEventCandidate::SOURCE_ETKINLIK_IO
    BASE_URL = "https://etkinlik.io/api/v2"

    DEFAULT_CITY_SLUGS = %w[istanbul ankara izmir antalya bursa eskisehir balikesir].freeze
    TARGET_CITY_IDS = {
      "ankara" => 7,
      "antalya" => 8,
      "balikesir" => 12,
      "bursa" => 21,
      "eskisehir" => 32,
      "istanbul" => 40,
      "izmir" => 41
    }.freeze

    FORMAT_OPTIONS = [
      [ "Atölye", 28, "atolye" ],
      [ "Çalıştay", 15, "calistay" ],
      [ "Eğitim", 5, "egitim" ],
      [ "Festival", 21, "festival" ],
      [ "Fuar", 4, "fuar" ],
      [ "Konferans", 2, "konferans" ],
      [ "Kongre", 8, "kongre" ],
      [ "Konser", 19, "konser" ],
      [ "Panel", 9, "panel" ],
      [ "Seminer", 3, "seminer" ],
      [ "Sergi", 1, "sergi" ],
      [ "Söyleşi", 14, "soylesi" ],
      [ "Webinar", 13, "webinar" ],
      [ "Zirve", 16, "zirve" ]
    ].freeze

    PRIORITY_FORMAT_IDS = [ 28, 15, 5, 21, 4, 2, 8, 19, 9, 3, 1, 14, 13, 16 ].freeze

    CATEGORY_OPTIONS = [
      [ "Alternatif Müzik", 1423, "alternatif-muzik" ],
      [ "Aşçılık ve Mutfak", 4015, "ascilik-ve-mutfak" ],
      [ "Bilim Teknoloji", 3797, "bilim-teknoloji" ],
      [ "Bilişim", 456, "bilisim" ],
      [ "Caz Müzik", 291, "caz-muzik" ],
      [ "Çocuk Gelişimi", 59, "cocuk-gelisimi" ],
      [ "Çocuk Tiyatrosu", 88, "cocuk-tiyatrosu" ],
      [ "Dans ve Müzikal Gösteriler", 3974, "dans-ve-muzikal-gosteriler" ],
      [ "Diğer", 3820, "diger" ],
      [ "Eğitim - Öğretim", 3968, "egitim-ogretim" ],
      [ "Finans-Ekonomi", 3798, "finans-ekonomi" ],
      [ "Girişimcilik", 54, "girisimcilik" ],
      [ "İş Dünyası", 354, "is-dunyasi" ],
      [ "Kariyer", 509, "kariyer" ],
      [ "Kişisel Gelişim", 24, "kisisel-gelisim" ],
      [ "Klasik Müzik", 170, "klasik-muzik" ],
      [ "Parti & Canlı Müzik", 3975, "parti-canli-muzik" ],
      [ "Pop Müzik", 63, "pop-muzik" ],
      [ "Rock Müzik", 300, "rock-muzik" ],
      [ "Sanat", 75, "sanat" ],
      [ "Spor", 1600, "spor" ],
      [ "Tiyatro ve Gösteriler", 3964, "tiyatro-ve-gosteriler" ],
      [ "Türk Sanat - Halk Müziği", 3985, "turk-sanat-halk-muzigi" ],
      [ "Üretim ve Mühendislik", 3966, "uretim-ve-muhendislik" ],
      [ "Yönetim ve Liderlik", 3967, "yonetim-ve-liderlik" ]
    ].freeze

    CITY_OPTIONS = TARGET_CITY_IDS.map { |slug, id| [ slug.tr("-", " ").titleize, id, slug ] }.freeze

    module_function

    def city_options(client: nil)
      client ||= Client.new
      Rails.cache.fetch("etkinlik_io/catalog/cities", expires_in: 6.hours) do
        catalog_rows(client.cities).filter_map do |row|
          id = row["id"]
          name = row["name"].presence
          slug = row["slug"].presence || name&.parameterize
          [ name, id, slug ] if id.present? && name.present? && slug.present?
        end.sort_by { |label, _id, _slug| label.to_s }
      end.presence || CITY_OPTIONS
    rescue Client::Error, Client::MissingTokenError
      CITY_OPTIONS
    end

    def format_options(client: nil)
      client ||= Client.new
      Rails.cache.fetch("etkinlik_io/catalog/formats", expires_in: 6.hours) do
        catalog_rows(client.formats).filter_map do |row|
          id = row["id"]
          name = row["name"].presence
          slug = row["slug"].presence || name&.parameterize
          [ name, id, slug ] if id.present? && name.present? && slug.present?
        end.sort_by { |label, _id, _slug| label.to_s }
      end.presence || FORMAT_OPTIONS
    rescue Client::Error, Client::MissingTokenError
      FORMAT_OPTIONS
    end

    def category_options(client: nil)
      client ||= Client.new
      Rails.cache.fetch("etkinlik_io/catalog/categories", expires_in: 6.hours) do
        catalog_rows(client.categories).filter_map do |row|
          id = row["id"]
          name = row["name"].presence
          slug = row["slug"].presence || name&.parameterize
          [ name, id, slug ] if id.present? && name.present? && slug.present?
        end.sort_by { |label, _id, _slug| label.to_s }
      end.presence || CATEGORY_OPTIONS
    rescue Client::Error, Client::MissingTokenError
      CATEGORY_OPTIONS
    end

    def catalog_rows(response)
      return response if response.is_a?(Array)
      return Array(response["items"] || response["data"] || response["cities"] || response["results"]) if response.is_a?(Hash)

      []
    end
  end
end
