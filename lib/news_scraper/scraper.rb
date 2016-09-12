module NewsScraper
  class Scraper
    def initialize(query:)
      @query = query
    end

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
