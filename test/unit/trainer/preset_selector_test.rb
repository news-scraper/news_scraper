require 'test_helper'

module NewsScraper
  module Trainer
    class PresetSelectorTest < Minitest::Test
      def setup
        super

        @domain = NewsScraper.configuration.scrape_patterns['domains'].keys.first
        @target_data_type = 'description'
      end

      def test_select_with_skip
        CLI.expects(:prompt_with_options).returns("skip")
        preset = PresetSelector.new(
          url: @domain,
          payload: ""
        )
        assert_nil preset.select(@target_data_type)
      end

      def test_select_with_custom_provider
        CLI.expects(:prompt_with_options).returns("#{PresetSelector::PROVIDER_PHRASE} xpath")
        CLI.expects(:get_input).returns('mock_xpath')

        preset = PresetSelector.new(
          url: @domain,
          payload: ""
        )

        assert_equal({ 'method' => 'xpath', 'pattern' => 'mock_xpath' }, preset.select(@target_data_type))
      end

      def test_select_with_preset
        option = Terminal::Table.new do |t|
          t << %w(method xpath)
          t << ['pattern', "//meta[@property='og:description']/@content"]
          t << %w(data description)
        end
        CLI.expects(:prompt_with_options).returns("\n#{option}")

        preset = PresetSelector.new(
          url: @domain,
          payload: "<meta content='description' property='og:description'>"
        )

        expected_select = NewsScraper.configuration
                                     .scrape_patterns['presets']['description']['og']
                                     .merge("variable" => "og_description")

        assert_equal(
          expected_select,
          preset.select(@target_data_type)
        )
      end
    end
  end
end
