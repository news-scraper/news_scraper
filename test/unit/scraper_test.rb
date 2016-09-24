require 'test_helper'

module NewsScraper
  class ScraperTest < Minitest::Test
    def setup
      super
      NewsScraper::Extractors::GoogleNewsRss.any_instance.expects(:extract).returns(['somearticle.com/shopify'])
      NewsScraper::Extractors::Article.any_instance.expects(:extract).returns('some payload')
      @transformed_data = {
        author: 'Richard Wu',
        body: 'Shopify is the greatest! 10/10 would recommend',
        description: 'Shopify is the greatest!',
        keywords: 'shopify,greatest',
        section: 'Technology',
        datetime: '1997-02-06T12:00:00+00:00:00',
        title: 'Shopify is Great',
        root_domain: 'somearticle.com'
      }
      NewsScraper::Transformers::Article.any_instance.expects(:transform).returns(@transformed_data)

      @scraper = NewsScraper::Scraper.new(query: 'shopify')
    end

    def test_scrape_returns_an_array_of_data_if_no_block_is_given
      assert_equal [@transformed_data], @scraper.scrape
    end

    def test_scrape_yields_each_transformed_article_if_block_is_given
      yielded_articles = []
      @scraper.scrape do |transformed_article|
        yielded_articles << transformed_article
      end

      assert_equal 1, yielded_articles.count
      assert_equal @transformed_data, yielded_articles.first
    end

    def test_scrape_also_returns_array_of_transformed_articles_if_block_is_given
      assert_equal [@transformed_data], @scraper.scrape { |_| }
    end
  end
end
