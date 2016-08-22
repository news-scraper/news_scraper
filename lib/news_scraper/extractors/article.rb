module NewsScraper
  module Extractors
    class Article
      include HTTPartyHelpers

      attr_accessor :uri

      def initialize(uri:)
        @uri = uri.match(/(https?)?(.*)/)[2]
      end

      def extract
        puts "Polling #{uri}"
        response = HTTParty.get("http://#{uri}")
        if response.code ==
      end
    end
  end
end
