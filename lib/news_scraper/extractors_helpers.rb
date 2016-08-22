module NewsScraper
  module ExtractorsHelpers
    def http_request(url)
      puts "Beginning HTTP request for #{url}"
      response = HTTParty.get(url)

      if response.code == 200
        puts "#{response.code} - #{response.message}. Request successful for #{url}"
        yield response
      else
        raise ResponseError, "#{response.code} - #{response.message}"
      end
    end
  end
end
