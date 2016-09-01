module NewsScraper
  class URIParser
    def initialize(url)
      @url = url
    end

    def without_scheme
      @url.gsub(%r(^https?://), '')
    end

    def host
      without_scheme.downcase.match(/^(?:[\w\d-]+\.)?(?<host>[\w\d-]+\.\w{2,})/)['host']
    end
  end
end
