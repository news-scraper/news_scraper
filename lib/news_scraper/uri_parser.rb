require 'uri'

module NewsScraper
  class URIParser
    def initialize(url)
      @uri = URI.parse(url)
    end

    def without_scheme
      @uri.scheme ? @uri.to_s.gsub(%r(^#{@uri.scheme}://), '') : @uri.to_s
    end

    def with_scheme
      @uri.scheme ? @uri.to_s : "http://#{@uri}"
    end

    def host
      without_scheme.downcase.match(/^(?:[\w\d-]+\.)?(?<host>[\w\d-]+\.\w{2,})/)['host']
    end
  end
end
