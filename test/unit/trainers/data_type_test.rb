require 'test_helper'

module NewsScraper
  module Trainer
    class DataTypeExtractorTest < Minitest::Test
      def setup
        super

        @domain = YAML.load_file('config/article_scrape_patterns.yml')['domains'].keys.first
        @target_data_type = 'description'
        @presets = NewsScraper::Transformers::Article.scrape_patterns['presets'][@target_data_type]
        @expected_transformation = transformation_fixture(@domain)
        @preset_results = [
          ["meta", @expected_transformation[:description]],
          ["og", @expected_transformation[:description]]
        ]
        @expected_select_options = [
          "meta_description: #{@expected_transformation[:description]}",
          "og_description: #{@expected_transformation[:description]}",
          'I will provide a pattern using xpath',
          'I will provide a pattern using css',
          'skip'
        ]
        @data_type_extractor = NewsScraper::Trainer::DataTypeExtractor.new(@domain)
      end

      def test_train_without_preset_results
        payload = raw_data_fixture(@domain)
        @data_type_extractor.stubs(:preset_results).returns([])

        expected_output = @data_type_extractor.blank_scrape_details.each_with_object({}) do |(k, _), h|
          h[k] = { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
        end

        capture_subprocess_io do
          assert_equal expected_output, @data_type_extractor.train(payload)
        end
      end

      def test_train_with_all_select_presets
        payload = raw_data_fixture(@domain)
        @data_type_extractor.stubs(:preset_results).returns(@preset_results)
        @data_type_extractor.stubs(:select_preset).returns(@presets['meta'])

        expected_output = @data_type_extractor.blank_scrape_details.each_with_object({}) do |(k, _), h|
          h[k] = @presets['meta']
        end

        capture_subprocess_io do
          assert_equal expected_output, @data_type_extractor.train(payload)
        end
      end

      def test_train_without_select_preset
        payload = raw_data_fixture(@domain)
        @data_type_extractor.stubs(:preset_results).returns(@preset_results)
        @data_type_extractor.stubs(:select_preset).returns(nil)

        expected_output = @data_type_extractor.blank_scrape_details.each_with_object({}) do |(k, _), h|
          h[k] = { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
        end

        capture_subprocess_io do
          assert_equal expected_output, @data_type_extractor.train(payload)
        end
      end

      def train(uri, payload)
        selected_presets = {}
        all_presets = Transformers::Article.scrape_patterns['presets']

        NewsScraper::CLI.put_header(uri)
        NewsScraper::CLI.log "Fetching information..."
        NewsScraper::CLI.put_footer

        data_types.each do |target_data_type|
          data_type_presets = all_presets[target_data_type]
          preset_results = preset_results(uri, payload, data_type_presets, target_data_type)

          NewsScraper::CLI.put_header("Determining information for #{target_data_type}")
          if preset_results.empty?
            NewsScraper::CLI.log("No presets were found for #{target_data_type}. Skipping to next.")
          else
            selected_preset = select_preset(preset_results, data_type_presets, target_data_type)
            selected_presets[target_data_type] = selected_preset if selected_preset
          end
          NewsScraper::CLI.put_footer

          selected_presets[target_data_type] ||= { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
        end

        selected_presets
      end

      def test_preset_results
        payload = raw_data_fixture(@domain)
        assert_equal @preset_results,
          @data_type_extractor.preset_results(payload, @presets, @target_data_type)
      end

      def test_preset_results_no_presets
        assert_equal({}, @data_type_extractor.preset_results(nil, nil, nil))
      end

      def test_blank_scrape_details
        expected_details = {
          "body" => nil,
          "description" => nil,
          "keywords" => nil,
          "section" => nil,
          "time" => nil,
          "title" => nil
        }
        assert_equal(expected_details, @data_type_extractor.blank_scrape_details)
      end

      def test_select_preset_with_skip
        NewsScraper::CLI.expects(:prompt_with_options).with(
          "Select which preset to use for #{@target_data_type}:",
          @expected_select_options
        ).returns('skip')
        assert_nil @data_type_extractor.select_preset(@preset_results, @presets, @target_data_type)
      end

      def test_select_preset_with_xpath
        NewsScraper::CLI.expects(:get_input).with('Provide the xpath pattern:').returns("xpath_pattern")
        NewsScraper::CLI.expects(:prompt_with_options).with(
          "Select which preset to use for #{@target_data_type}:",
          @expected_select_options
        ).returns('I will provide a pattern using xpath')
        assert_equal({
          "method"=>"xpath",
          "pattern"=>"xpath_pattern"
        }, @data_type_extractor.select_preset(@preset_results, @presets, @target_data_type))
      end

      def test_select_preset_with_css
        NewsScraper::CLI.expects(:get_input).with('Provide the css pattern:').returns("css_pattern")
        NewsScraper::CLI.expects(:prompt_with_options).with(
          "Select which preset to use for #{@target_data_type}:",
          @expected_select_options
        ).returns('I will provide a pattern using css')
        assert_equal({
          "method"=>"css",
          "pattern"=>"css_pattern"
        }, @data_type_extractor.select_preset(@preset_results, @presets, @target_data_type))
      end

      def test_select_preset_with_option
        NewsScraper::CLI.expects(:prompt_with_options).with(
          "Select which preset to use for #{@target_data_type}:",
          @expected_select_options
        ).returns(@expected_select_options.first)

        assert_equal @presets['meta'],
          @data_type_extractor.select_preset(@preset_results, @presets, @target_data_type)
      end
    end
  end
end
