require 'test_helper'

module NewsScraper
  module Trainer
    class PresetSelectorTest < Minitest::Test
      def setup
        super

        @domain = NewsScraper::Constants::SCRAPE_PATTERNS['domains'].keys.first
        @target_data_type = 'description'
        @data_type_presets = NewsScraper::Constants::SCRAPE_PATTERNS['presets'][@target_data_type]
      end

      def test_select_without_data_type_presets
        assert_nil PresetSelector.new(
          uri: @domain,
          payload: "",
          data_type_presets: nil,
          data_type: @target_data_type
        ).select
      end

      def test_select_with_skip
        CLI.expects(:prompt_with_options).returns("skip")
        preset = PresetSelector.new(
          uri: @domain,
          payload: "",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type
        )
        assert_nil preset.select
      end

      def test_select_with_custom_provider
        CLI.expects(:prompt_with_options).returns("#{PresetSelector::PROVIDER_PHRASE} xpath")
        CLI.expects(:get_input).returns('mock_xpath')

        preset = PresetSelector.new(
          uri: @domain,
          payload: "",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type
        )

        assert_equal({ 'method' => 'xpath', 'pattern' => 'mock_xpath' }, preset.select)
      end

      def test_select_with_preset
        CLI.expects(:prompt_with_options).returns("og_description: description")

        preset = PresetSelector.new(
          uri: @domain,
          payload: "<meta content='description' property='og:description'>",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type
        )

        assert_equal(NewsScraper::Constants::SCRAPE_PATTERNS['presets']['description']['og'], preset.select)
      end
    end
  end
end
