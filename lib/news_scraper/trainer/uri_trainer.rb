require 'pry'

module NewsScraper
  module Trainer
    class UriTrainer
      def initialize(uri)
        uri_parser = URIParser.new(uri)
        @uri = uri_parser.without_scheme
        @root_domain = uri_parser.host
        @payload = Extractors::Article.new(url: @uri).extract
      end

      def train
        return if article_scrape_patterns['domains'].key?(@root_domain)

        CLI.put_header(@root_domain)
        CLI.log("There is no scrape pattern defined for #{@root_domain} in config/article_scrape_patterns.yml")
        CLI.log "Fetching information..."
        CLI.put_footer

        selected_presets = {}
        article_scrape_patterns['data_types'].each do |data_type|
          selected_presets[data_type] = pattern(data_type)
        end

        save_selected_presets(selected_presets)
      end

      private

      def pattern(data_type)
        CLI.put_header("Determining information for #{data_type}")
        data_type_presets = article_scrape_patterns['presets'][data_type]
        pattern = if data_type_presets.nil? || data_type_presets.empty?
          CLI.log("No presets were found for #{data_type}. Skipping to next.")
          nil
        else
          Preset.new(
            uri: @uri,
            scrape_patterns: article_scrape_patterns,
            payload: @payload,
            data_type_presets: data_type_presets,
            data_type: data_type
          ).select
        end
        CLI.put_footer

        pattern || { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
      end

      def save_selected_presets(selected_presets)
        save_domain_presets = if article_scrape_patterns['domains'].key?(@root_domain)
          CLI.log("YAML file already contains scrape pattern for #{@root_domain}:")
          CLI.log_lines(article_scrape_patterns['domains'][@root_domain].to_yaml)
          CLI.confirm("Overwrite?")
        else
          true
        end

        if save_domain_presets
          article_scrape_patterns['domains'][@root_domain] = selected_presets
          File.write('config/article_scrape_patterns.yml', article_scrape_patterns.to_yaml)
          CLI.log("Successfully wrote presets for #{@root_domain} to config/article_scrape_patterns.yml.")
        else
          CLI.log("Did not write presets for #{@root_domain} to file.")
        end
      end

      def article_scrape_patterns
        @article_scrape_patterns ||= YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)
      end
    end
  end
end
