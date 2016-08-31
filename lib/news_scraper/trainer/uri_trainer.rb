module NewsScraper
  module Trainer
    class UriTrainer
      def initialize(uri)
        @article_scrape_patterns = YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)
        @data_type = Trainer::PresetsSelector.new(uri)

        @uri = uri
        @raw_html = Extractors::Article.new(uri: uri).extract
        @transformer = Transformers::Article.new(
          uri: uri,
          payload: @raw_html,
          scrape_patterns: @article_scrape_patterns
        )
      end

      def train
        begin
          @transformer.transform
        rescue Transformers::ScrapePatternNotDefined => e
          CLI.put_header
          CLI.log("There is no scrape pattern defined for #{e.root_domain}"\
            " in config/article_scrape_patterns.yml")
          no_scrape_defined(e.root_domain)
        end
      end

      def no_scrape_defined(root_domain)
        if CLI.confirm("Step through presets for #{root_domain}?")
          CLI.put_footer
          selected_presets = @data_type.train(@raw_html)

          CLI.put_header('Save preset')
          CLI.log_lines(selected_presets.to_yaml)
          if CLI.confirm("Save these scrape patterns for #{root_domain}?")
            save_selected_presets(root_domain, selected_presets)
          end
        else
          CLI.log("Ignoring step-through for #{root_domain}", color: '\x1b[31m')
        end

        CLI.put_footer
      end

      def save_selected_presets(root_domain, selected_presets)
        save_domain_presets = if @article_scrape_patterns['domains'].key?(root_domain)
          CLI.log("YAML file already contains scrape pattern for #{root_domain}:")
          CLI.log_lines(@article_scrape_patterns['domains'][root_domain].to_yaml)
          CLI.confirm("Overwrite?")
        else
          true
        end

        if save_domain_presets
          @article_scrape_patterns['domains'][root_domain] = selected_presets
          File.write('config/article_scrape_patterns.yml', @article_scrape_patterns.to_yaml)
          CLI.log("Successfully wrote presets for #{root_domain} to config/article_scrape_patterns.yml.")
        else
          CLI.log("Did not write presets for #{root_domain} to file.")
        end
      end
    end
  end
end
