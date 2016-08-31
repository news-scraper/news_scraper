module NewsScraper
  module Trainer
    module UriTrainer
      extend self

      def train(uri)
        raw_html = Extractors::Article.new(uri: uri).extract
        transformer = Transformers::Article.new(uri: uri, payload: raw_html)

        begin
          transformer.transform
        rescue NewsScraper::Transformers::ScrapePatternNotDefined => e
          NewsScraper::CLI.put_header
          NewsScraper::CLI.log("There is no scrape pattern defined for #{e.root_domain} in config/article_scrape_patterns.yml")
          no_scrape_defined(uri, raw_html, e.root_domain)
        end
      end

      def no_scrape_defined(uri, raw_html, root_domain)
        if NewsScraper::CLI.confirm("Step through presets for #{root_domain}?")
          NewsScraper::CLI.put_footer
          all_presets = Transformers::Article.scrape_patterns['presets']
          selected_presets = NewsScraper::Trainer::DataType.train(uri, raw_html, all_presets)

          NewsScraper::CLI.put_header('Save preset')
          NewsScraper::CLI.log_lines(selected_presets.to_yaml)
          if NewsScraper::CLI.confirm("Save these scrape patterns for #{root_domain}?")
            save_selected_presets(root_domain, selected_presets)
          end
        else
          NewsScraper::CLI.log("Ignoring step-through for #{root_domain}", color: '\x1b[31m')
        end

        NewsScraper::CLI.put_footer
      end

      def save_selected_presets(root_domain, selected_presets)
        article_scrape_patterns = Transformers::Article.scrape_patterns
        save_domain_presets = if article_scrape_patterns['domains'].key?(root_domain)
          NewsScraper::CLI.log("YAML file already contains scrape pattern for #{root_domain}:")
          NewsScraper::CLI.log_lines(article_scrape_patterns['domains'][root_domain].to_yaml)
          NewsScraper::CLI.confirm("Overwrite?")
        else
          true
        end

        if save_domain_presets
          article_scrape_patterns['domains'][root_domain] = selected_presets
          File.write('config/article_scrape_patterns.yml', article_scrape_patterns.to_yaml)
          NewsScraper::CLI.log("Successfully wrote presets for #{root_domain} to config/article_scrape_patterns.yml.")
        else
          NewsScraper::CLI.log("Did not write presets for #{root_domain} to file.")
        end
      end
    end
  end
end
