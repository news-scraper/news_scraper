require 'test_helper'

module NewsScraper
  module Trainer
    class UriTrainerTest < Minitest::Test
      def setup
        super
        NewsScraper::Transformers::Article.any_instance.stubs(:transform)
        NewsScraper::Extractors::Article.any_instance.stubs(:extract)
      end

      def test_train_with_defined_scraper_pattern
        NewsScraper::Transformers::Article.any_instance.expects(:transform)
        NewsScraper::Extractors::Article.any_instance.expects(:extract)

        capture_subprocess_io do
          trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
          trainer.expects(:no_scrape_defined).never
          trainer.train
        end
      end

      def test_train_with_no_defined_scraper_pattern
        NewsScraper::Transformers::Article.any_instance.expects(:transform).raises(
          NewsScraper::Transformers::ScrapePatternNotDefined.new(root_domain: 'google.ca')
        )
        NewsScraper::Extractors::Article.any_instance.expects(:extract).returns('extract')

        capture_subprocess_io do
          trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
          trainer.expects(:no_scrape_defined).with('google.ca', 'extract', 'google.ca')
          trainer.train
        end
      end

      def test_no_scrape_defined_with_no_step_through
        NewsScraper::CLI.expects(:confirm).returns(false)
        NewsScraper::Trainer::DataTypeExtractor.any_instance.expects(:train).never

        capture_subprocess_io do
          trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
          trainer.expects(:save_selected_presets).never
          trainer.no_scrape_defined('google.ca', '', 'google.ca')
        end
      end

      def test_no_scrape_defined_with_no_save
        NewsScraper::CLI.expects(:confirm).twice.returns(true, false)
        NewsScraper::Trainer::DataTypeExtractor.any_instance.expects(:train).returns({})

        capture_subprocess_io do
          trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
          trainer.expects(:save_selected_presets).never
          trainer.no_scrape_defined('google.ca', '', 'google.ca')
        end
      end

      def test_no_scrape_defined_with_save
        NewsScraper::CLI.expects(:confirm).twice.returns(true, true)
        NewsScraper::Trainer::DataTypeExtractor.any_instance.expects(:train).returns('selected_presets' => 'selected_presets')

        capture_subprocess_io do
          trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
          trainer.expects(:save_selected_presets).with(
            'google.ca',
            'selected_presets' => 'selected_presets'
          )
          trainer.no_scrape_defined('google.ca', '', 'google.ca')
        end
      end

      def test_save_selected_presets_saves_config
        assert_presets_written('totally-not-there.com')
      end

      def test_save_selected_presets_saves_config_twice
        domain = 'totally-not-there.com'
        assert_presets_written(domain)
        assert_presets_written(domain, presets: mock_presets('.pattern2'), overwrite_confirm: true)
      end

      def test_save_selected_presets_saves_overwrite
        domain = NewsScraper::Transformers::Article.scrape_patterns['domains'].keys.first
        assert_presets_written(domain, overwrite_confirm: true)
      end

      def test_save_selected_presets_no_overwrite
        domain = NewsScraper::Transformers::Article.scrape_patterns['domains'].keys.first
        original_presets = NewsScraper::Transformers::Article.scrape_patterns['domains'][domain]
        assert_equal original_presets, assert_presets_written(domain, overwrite_confirm: false)
      end

      def assert_presets_written(domain, presets: mock_presets('.pattern'), overwrite_confirm: false)
        yaml_path = 'config/article_scrape_patterns.yml'
        NewsScraper::CLI.stubs(:confirm).returns(overwrite_confirm)

        Dir.mktmpdir do |dir|
          # Copy the yaml file to the tmp dir so we don't modify the main file in a test
          tmp_yaml_path = File.join(dir, yaml_path)
          FileUtils.mkpath(File.dirname(tmp_yaml_path))
          FileUtils.cp(yaml_path, tmp_yaml_path)

          # Chdir to the temp dir so we load the temp file
          Dir.chdir(dir) do
            capture_subprocess_io do
              trainer = NewsScraper::Trainer::UriTrainer.new('google.ca')
              trainer.save_selected_presets(domain, presets)
            end
            assert_equal presets, YAML.load_file(tmp_yaml_path)['domains'][domain] if overwrite_confirm
            YAML.load_file(tmp_yaml_path)['domains'][domain]
          end
        end
      end

      def mock_presets(pattern = '.pattern')
        %w(body description keywords section time title).each_with_object({}) do |p, preset|
          preset[p] = { 'method' => 'css', 'pattern' => pattern }
        end
      end
    end
  end
end
