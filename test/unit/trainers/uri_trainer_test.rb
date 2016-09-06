require 'test_helper'

module NewsScraper
  module Trainer
    class UriTrainerTest < Minitest::Test
      def setup
        super
        Transformers::Article.any_instance.stubs(:transform)
        Extractors::Article.any_instance.stubs(:extract)
      end

      def test_train
        PresetSelector.any_instance.stubs(:select).returns('pattern_mock' => 'pattern_mock')
        expected_patterns = {
          'author' => { 'pattern_mock' => 'pattern_mock' },
          'body' => { 'pattern_mock' => 'pattern_mock' },
          'description' => { 'pattern_mock' => 'pattern_mock' },
          'keywords' => { 'pattern_mock' => 'pattern_mock' },
          'section' => { 'pattern_mock' => 'pattern_mock' },
          'datetime' => { 'pattern_mock' => 'pattern_mock' },
          'title' => { 'pattern_mock' => 'pattern_mock' }
        }

        temporary_scrape_patterns_test do |config_path|
          Trainer::UriTrainer.new('yolo.com').train
          assert_equal expected_patterns, YAML.load_file(config_path)['domains']['yolo.com']
        end
      end

      def test_train_with_variables_associates_to_the_correct_yaml_variable
        PresetSelector.any_instance.stubs(:select).returns('variable' => 'link_author')
        expected_output = <<EOF
  yolo.com:
    author: *link_author
    body: *link_author
    description: *link_author
    keywords: *link_author
    section: *link_author
    datetime: *link_author
    title: *link_author
EOF
        temporary_scrape_patterns_test do |config_path|
          Trainer::UriTrainer.new('yolo.com').train
          assert_equal expected_output, File.readlines(config_path).last(expected_output.count("\n")).join
        end
      end

      def test_train_on_trained_domain_returns_without_stepping_through_presets
        domain = Constants::SCRAPE_PATTERNS['domains'].keys.first
        capture_subprocess_io do
          assert_nil Trainer::UriTrainer.new(domain).train
          assert_equal Constants::SCRAPE_PATTERNS['domains'][domain],
            YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)['domains'][domain]
        end
      end
    end
  end
end
