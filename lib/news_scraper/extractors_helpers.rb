module NewsScraper
  module ExtractorsHelpers
    # Perform an HTTP request with a standardized response
    #
    # *Params*
    # - <code>url</code>: the url on which to perform a get request
    #
    def http_request(url)
      url = URIParser.new(url).with_scheme

      CLI.put_header(url)
      CLI.log "Beginning HTTP request for #{url}"
      response = HTTParty.get(url)

      raise ResponseError.new("#{response.code} - #{response.message}") unless response.code == 200

      CLI.log "#{response.code} - #{response.message}. Request successful for #{url}"
      CLI.put_footer

      if block_given?
        yield response
      else
        response
      end
    end
  end
end
