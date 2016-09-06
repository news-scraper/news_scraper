module NewsScraper
  module Trainer
    class UriTrainer
      def initialize(uri)
        uri_parser = URIParser.new(uri)
        @uri = uri_parser.without_scheme
        @root_domain = uri_parser.host
      end

      def train(automated: false)
        return if article_scrape_patterns['domains'].key?(@root_domain)
        @payload = Extractors::Article.new(url: @uri).extract

        CLI.put_header(@root_domain)
        CLI.log("There is no scrape pattern defined for #{@root_domain} in #{Constants::SCRAPE_PATTERN_FILEPATH}")
        CLI.log "Fetching information..."
        CLI.put_footer

        selected_presets = {}
        article_scrape_patterns['data_types'].each do |data_type|
          selected = selected_pattern(data_type, automated: automated)
          return if selected.nil?
          selected_presets[data_type] = selected
        end

        save_selected_presets(selected_presets)
      end

      private

      def selected_pattern(data_type, automated: false)
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
            data_type: data_type,
            automated: automated
          ).select
        end

        if pattern
          CLI.log("Determined #{pattern} for #{data_type} for domain #{@root_domain}")
        else
          CLI.log("Could not find pattern for #{data_type} for domain #{@root_domain}")
          # Log the domain? Try again later with more presets? manual?
          return
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
