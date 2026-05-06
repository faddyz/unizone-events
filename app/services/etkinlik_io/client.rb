require "json"
require "net/http"
require "uri"

module EtkinlikIo
  class Client
    class Error < StandardError; end
    class MissingTokenError < Error; end

    attr_reader :token

    def initialize(token: self.class.default_token, base_url: Catalog::BASE_URL)
      @token = token.to_s.strip
      @base_url = base_url
      raise MissingTokenError, "ETKINLIK_API_TOKEN is missing" if @token.blank?
    end

    def self.default_token
      ENV["ETKINLIK_API_TOKEN"].presence || token_from_api_env
    end

    def self.token_from_api_env
      path = Rails.root.join("api.env")
      return if !File.exist?(path)

      File.readlines(path, chomp: true).each do |line|
        next if line.blank? || line.start_with?("#")

        key, value = line.split("=", 2)
        return value.to_s.strip if key == "ETKINLIK_API_TOKEN"
      end

      nil
    end

    def get(path, params = {})
      uri = uri_for(path, params.compact_blank)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["X-Etkinlik-Token"] = token

      response = perform_request(uri, request)
      raise Error, "Etkinlik.io request failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body.to_s)
    rescue JSON::ParserError => error
      raise Error, "Etkinlik.io returned invalid JSON: #{error.message}"
    end

    def cities
      get("/cities")
    end

    def formats
      get("/formats")
    end

    def categories
      get("/categories")
    end

    def events(params = {})
      get("/events", params)
    end

    private

    def uri_for(path, params)
      uri = URI("#{@base_url}#{path}")
      uri.query = URI.encode_www_form(params) if params.present?
      uri
    end

    def perform_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 25) do |http|
        http.request(request)
      end
    end
  end
end
