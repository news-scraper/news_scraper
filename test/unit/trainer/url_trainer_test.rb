require 'test_helper'
require 'tempfile'

module NewsScraper
  module Trainer
    class UrlTrainerTest < Minitest::Test
      def setup
        super
        Transformers::TrainerArticle.any_instance.stubs(:transform)
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

        capture_subprocess_io do
          Trainer::UrlTrainer.new(url: 'yolo.com').train
        end
        assert_equal expected_patterns,
          YAML.load_file(NewsScraper.configuration.scrape_patterns_filepath)['domains']['yolo.com']
      end

      def test_train_will_append_with_correct_yaml_anchors
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
        capture_subprocess_io do
          Trainer::UrlTrainer.new(url: 'yolo.com').train
        end
        assert_equal expected_output,
          File.readlines(NewsScraper.configuration.scrape_patterns_filepath).last(expected_output.count("\n")).join
      end

      def test_train_on_trained_domain_returns_without_stepping_through_presets
        domain = NewsScraper.configuration.scrape_patterns['domains'].keys.first
        capture_subprocess_io do
          assert_nil Trainer::UrlTrainer.new(url: domain).train
          assert_equal NewsScraper.configuration.scrape_patterns['domains'][domain],
            YAML.load_file(NewsScraper.configuration.scrape_patterns_filepath)['domains'][domain]
        end
      end
    end
  end
end
