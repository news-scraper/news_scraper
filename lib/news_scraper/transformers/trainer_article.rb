module NewsScraper
  module Transformers
    class TrainerArticle < Article
      # Initialize a TrainerArticle object
      #
      # *Params*
      # - <code>url</code>: keyword arg - the url on which scraping was done
      # - <code>payload</code>: keyword arg - the result of the scrape
      # - <code>scrape_details</code>: keyword arg - The pattern/methods for the domain to use in the transformation
      #
      def initialize(url:, payload:, scrape_details:, configuration:)
        @scrape_details = scrape_details
        super(url: url, payload: payload, configuration: configuration)
      end
    end
  end
end
