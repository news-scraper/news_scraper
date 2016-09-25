require 'test_helper'

module NewsScraper
  module Transformers
    class TrainerArticleTest < Minitest::Test
      def test_transform_returns_full_preset_data
        domain = NewsScraper.configuration.scrape_patterns['domains'].keys.first
        raw_data = raw_data_fixture(domain)
        transformer = NewsScraper::Transformers::TrainerArticle.new(
          url: "#{domain}/some_article",
          payload: raw_data
        )

        expected_transformation = trainer_transformation_fixture(domain)
        assert_equal expected_transformation, transformer.transform
      end
    end
  end
end
