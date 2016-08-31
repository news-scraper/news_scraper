module NewsScraper
  module ExtractorsHelpers
    def http_request(url)
      NewsScraper::CLI.put_header(url)
      NewsScraper::CLI.log "Beginning HTTP request for #{url}"
      response = HTTParty.get(url)

      if response.code == 200
        NewsScraper::CLI.log "#{response.code} - #{response.message}. Request successful for #{url}"
        NewsScraper::CLI.put_footer
        yield response
      else
        raise ResponseError, "#{response.code} - #{response.message}"
      end
    end
  end
end
