require 'test_helper'

module NewsScraper
  module Trainer
    class PresetSelectorTest < Minitest::Test
      def setup
        super

        @domain = default_configuration.scrape_patterns['domains'].keys.first
        @target_data_type = 'description'
        @data_type_presets = default_configuration.scrape_patterns['presets'][@target_data_type]
      end

      def test_select_without_data_type_presets
        assert_nil PresetSelector.new(
          url: @domain,
          payload: "",
          data_type_presets: nil,
          data_type: @target_data_type,
          configuration: default_configuration
        ).select
      end

      def test_select_with_skip
        CLI.expects(:prompt_with_options).returns("skip")
        preset = PresetSelector.new(
          url: @domain,
          payload: "",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type,
          configuration: default_configuration
        )
        assert_nil preset.select
      end

      def test_select_with_custom_provider
        CLI.expects(:prompt_with_options).returns("#{PresetSelector::PROVIDER_PHRASE} xpath")
        CLI.expects(:get_input).returns('mock_xpath')

        preset = PresetSelector.new(
          url: @domain,
          payload: "",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type,
          configuration: default_configuration
        )

        assert_equal({ 'method' => 'xpath', 'pattern' => 'mock_xpath' }, preset.select)
      end

      def test_select_with_preset
        CLI.expects(:prompt_with_options).returns("og_description: description")

        preset = PresetSelector.new(
          url: @domain,
          payload: "<meta content='description' property='og:description'>",
          data_type_presets: @data_type_presets,
          data_type: @target_data_type,
          configuration: default_configuration
        )

        assert_equal(
          default_configuration.scrape_patterns['presets']['description']['og'].merge("variable" => "og_description"),
          preset.select
        )
      end
    end
  end
end
