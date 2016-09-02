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
        CLI.put_header(@root_domain)
        CLI.log("There is no scrape pattern defined for #{@root_domain} in #{Constants::SCRAPE_PATTERN_FILEPATH}")
        CLI.log "Fetching information..."
        CLI.put_footer

        selected_presets = {}
        article_scrape_patterns['data_types'].each do |data_type|
          selected_presets[data_type] = selected_pattern(data_type)
        end

        save_selected_presets(selected_presets)
        selected_presets
      end

      private

      def selected_pattern(data_type)
        CLI.put_header("Determining information for #{data_type}")
        data_type_presets = article_scrape_patterns['presets'][data_type]
        pattern = if data_type_presets.nil?
          CLI.log("No presets were found for #{data_type}. Skipping to next.")
          nil
        else
          PresetSelector.new(
            uri: @uri,
            payload: @payload,
            data_type_presets: data_type_presets,
            data_type: data_type
          ).select
        end
        CLI.put_footer

        pattern || { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
      end

      def save_selected_presets(selected_presets)
        article_scrape_patterns['domains'][@root_domain] = selected_presets
        File.write(Constants::SCRAPE_PATTERN_FILEPATH, article_scrape_patterns.to_yaml)
        CLI.log("Successfully wrote presets for #{@root_domain} to #{Constants::SCRAPE_PATTERN_FILEPATH}.")
      end

      def article_scrape_patterns
        @article_scrape_patterns ||= YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)
      end
    end
  end
end
