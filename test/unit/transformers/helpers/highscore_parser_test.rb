require 'test_helper'

module NewsScraper
  module Transformers
    module Helpers
      class HighScoreParserTest < Minitest::Test
        def test_string_join
          longest_stopword = NewsScraper.configuration.stopwords.sort_by(&:size).last
          expected_keywords = %w(payload banana kiwi richard julian)
          payload = "#{longest_stopword} " * 50 + " #{expected_keywords.join(' ')} " * 2
          assert_equal expected_keywords.sort, HighScoreParser.parse(url: 'https://google.com', payload: payload)
        end
      end
    end
  end
end
