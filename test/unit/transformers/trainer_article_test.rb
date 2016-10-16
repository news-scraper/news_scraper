require 'test_helper'

module NewsScraper
  module Transformers
    class TrainerArticleTest < Minitest::Test
      def test_transform_returns_full_preset_data
        Helpers::HighScoreParser.expects(:keywords).returns(%w(shopify company growth price businesses))
        domain = NewsScraper.configuration.scrape_patterns['domains'].keys.first
        raw_data = raw_data_fixture(domain)
        transformer = NewsScraper::Transformers::TrainerArticle.new(
          url: "https://#{domain}/some_article",
          payload: raw_data
        )

        expected_transformation = trainer_transformation_fixture(domain)
        actual_transformation = transformer.transform
        assert_equal expected_transformation, actual_transformation,
          hash_diff_message(expected_transformation, actual_transformation)
      end
    end
  end
end
