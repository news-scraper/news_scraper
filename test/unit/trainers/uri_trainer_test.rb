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
        PresetSelector.any_instance.stubs(:select).returns('pattern_mock')
        expected_patterns = {
          'author' => 'pattern_mock',
          'body' => 'pattern_mock',
          'description' => 'pattern_mock',
          'keywords' => 'pattern_mock',
          'section' => 'pattern_mock',
          'datetime' => 'pattern_mock',
          'title' => 'pattern_mock'
        }

        # Use a tmp dir so as not to override the actual config/article_scrape_patterns.yml
        Dir.mktmpdir do |dir|
          config_path = File.join(dir, Constants::SCRAPE_PATTERN_FILEPATH)
          FileUtils.mkpath(File.dirname(config_path))

          Dir.chdir(dir) do
            File.write(config_path, Constants::SCRAPE_PATTERNS.to_yaml)

            capture_subprocess_io do
              Trainer::UriTrainer.new('yolo.com').train
              assert_equal expected_patterns, YAML.load_file(config_path)['domains']['yolo.com']
            end
          end
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
