require 'uri'

module NewsScraper
  class URIParser
    # Initialize a URIParser
    #
    # *Params*
    # - <code>uri</code>: the uri to parse
    #
    def initialize(uri)
      @uri = URI.parse(uri)
    end

    # Removes the scheme from the URI
    #
    # *Returns*
    # - A schemeless URI string, e.g. https://google.ca will return google.ca
    #
    def without_scheme
      @uri.scheme ? @uri.to_s.gsub(%r{^#{@uri.scheme}://}, '') : @uri.to_s
    end

    # Returns the URI with a scheme, adding http:// if no scheme is present
    #
    # *Returns*
    # - A URI string, with http:// if no scheme was specified
    #
    def with_scheme
      @uri.scheme ? @uri.to_s : "http://#{@uri}"
    end

    # Returns the URI's host, removing paths, params, and schemes
    #
    # *Returns*
    # - The URI's host, e.g. https://google.ca/search&q=query will return google.ca
    #
    def host
      without_scheme.downcase.match(/^(?:[\w\d-]+\.)?(?<host>[\w\d-]+\.\w{2,})/)['host']
    end
  end
end
