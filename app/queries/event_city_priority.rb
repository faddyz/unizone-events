class EventCityPriority
  TOP_PRIORITY_CITIES = [
    "İstanbul",
    "İzmir",
    "Ankara"
  ].freeze

  METROPOLITAN_CITIES = [
    "Adana",
    "Antalya",
    "Aydın",
    "Balıkesir",
    "Bursa",
    "Denizli",
    "Diyarbakır",
    "Erzurum",
    "Eskişehir",
    "Gaziantep",
    "Hatay",
    "Kahramanmaraş",
    "Kayseri",
    "Kocaeli",
    "Konya",
    "Malatya",
    "Manisa",
    "Mardin",
    "Mersin",
    "Muğla",
    "Ordu",
    "Sakarya",
    "Samsun",
    "Şanlıurfa",
    "Tekirdağ",
    "Trabzon",
    "Van"
  ].freeze

  class << self
    def order_sql(table_name: "events")
      "#{score_sql(table_name: table_name)} ASC"
    end

    def score_sql(table_name: "events")
      city_column = "#{table_name}.city"

      <<~SQL.squish
        CASE
          WHEN #{city_column} IN (#{quoted_cities(TOP_PRIORITY_CITIES)}) THEN 0
          WHEN #{city_column} IN (#{quoted_cities(METROPOLITAN_CITIES)}) THEN 1
          ELSE 2
        END
      SQL
    end

    private

    def quoted_cities(cities)
      cities.map { |city| ActiveRecord::Base.connection.quote(city) }.join(", ")
    end
  end
end
