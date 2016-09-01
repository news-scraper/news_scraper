module NewsScraper
  module ExtractorsHelpers
    def http_request(url)
      CLI.put_header(url)
      CLI.log "Beginning HTTP request for #{url}"
      response = HTTParty.get(url)

      if response.code == 200
        CLI.log "#{response.code} - #{response.message}. Request successful for #{url}"
        CLI.put_footer
        yield response
      else
        raise ResponseError, "#{response.code} - #{response.message}"
      end
    end
  end
end
