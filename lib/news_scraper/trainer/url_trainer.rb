module NewsScraper
  module Trainer
    class UrlTrainer
      def initialize(url)
        @url = url
        @root_domain = URIParser.new(@url).host
        @payload = Extractors::Article.new(url: @url).extract
      end

      def train
        return if article_scrape_patterns['domains'].key?(@root_domain)

        CLI.put_header(@root_domain)
        CLI.log("There is no scrape pattern defined for #{@root_domain} in #{Constants::SCRAPE_PATTERN_FILEPATH}")
        CLI.log "Fetching information..."
        CLI.put_footer

        selected_presets = {}
        article_scrape_patterns['data_types'].each do |data_type|
          selected_presets[data_type] = selected_pattern(data_type)
        end

        save_selected_presets(selected_presets)
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
            url: @url,
            payload: @payload,
            data_type_presets: data_type_presets,
            data_type: data_type
          ).select
        end
        CLI.put_footer

        pattern || { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
      end

      def save_selected_presets(selected_presets)
        current_content = File.read(Constants::SCRAPE_PATTERN_FILEPATH).chomp
        new_content = "#{current_content}\n#{build_domain_yaml(selected_presets)}\n"

        File.write(Constants::SCRAPE_PATTERN_FILEPATH, new_content)
        CLI.log("Successfully wrote presets for #{@root_domain} to #{Constants::SCRAPE_PATTERN_FILEPATH}.")
      end

      def build_domain_yaml(selected_presets)
        spacer = "  "
        output_string = ["#{spacer}#{@root_domain}:"]
        selected_presets.each do |data_type, spec|
          if spec.include?('variable')
            output_string << (spacer * 2) + "#{data_type}: *#{spec['variable']}"
          else
            output_string << (spacer * 2) + "#{data_type}:"
            spec.each { |k, v| output_string << (spacer * 3) + "#{k}: #{v}" }
          end
        end
        output_string.join("\n")
      end

      def article_scrape_patterns
        @article_scrape_patterns ||= YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)
      end
    end
  end
end
