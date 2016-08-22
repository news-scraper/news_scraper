module NewsScraper
  module ExtractorsHelper
    def http_request(url)
      response = HTTParty.get(
        url
      )

      if response.code == 200
        yield response
      else
        raise NewsScraper::ResponseError, "#{response.code} - #{response.message}"
      end
    end
  end
end
