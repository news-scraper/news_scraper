module NewsScraper
  class Scraper
    # Initialize a Scraper object
    #
    # *Params*
    # - <code>query</code>: a keyword arugment specifying the query to scrape
    #
    def initialize(query:)
      @query = query
    end

    # Fetches articles from Extraction sources and scrapes the results
    #
    # *Yields*
    # - Will yield individually extracted sources
    #
    # *Raises*
    # - Will raise a `Transformers::ScrapePatternNotDefined` if an article is not in the root domains
    # - This root domain will need to be trained, it would be helpful to have a PR created to add this
    #
    # *Returns*
    # - <code>transformed_articles</code>: The transformed articles fetched from the extracted sources
    #
    def scrape
      article_urls = Extractors::GoogleNewsRss.new(query: @query).extract

      transformed_articles = []
      article_urls.each do |article_url|
        payload = Extractors::Article.new(url: article_url).extract

        transformed_article = Transformers::Article.new(url: article_url, payload: payload).transform
        transformed_articles << transformed_article

        yield transformed_article if block_given?
      end

      transformed_articles
    end
  end
end
