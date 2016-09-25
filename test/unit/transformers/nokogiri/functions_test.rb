require 'test_helper'
require 'nokogiri'

module NewsScraper
  module Transformers
    module Nokogiri
      class FunctionsTest < Minitest::Test
        def test_string_join
          test_html = %w(
            <div>
            <p>text1</p>
            <p>text2</p>
            </div>
          ).join

          noko_html = ::Nokogiri::HTML(test_html)
          result = noko_html.xpath("string-join(//div/p/text(), ',')", Nokogiri::Functions.new)
          assert_equal "text1,text2", result
        end
      end
    end
  end
end
