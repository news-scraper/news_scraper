module NewsScraper
  module Trainer
    class UrlTrainer
      def initialize(url)
        @url = url
        @root_domain = URIParser.new(@url).host
        @payload = Extractors::Article.new(url: @url).extract
      end

      def train
        return if NewsScraper.configuration.scrape_patterns['domains'].key?(@root_domain)

        CLI.put_header(@root_domain)
        CLI.log("There is no scrape pattern defined for #{@root_domain} in"\
          " #{NewsScraper.configuration.scrape_patterns_filepath}")
        CLI.log "Fetching information..."
        CLI.put_footer

        selected_presets = {}
        NewsScraper.configuration.scrape_patterns['data_types'].each do |data_type|
          selected_presets[data_type] = selected_pattern(data_type)
        end
        save_selected_presets(selected_presets)
      end

      private

      def selected_pattern(data_type)
        CLI.put_header("Determining information for #{data_type}")
        pattern = if NewsScraper.configuration.scrape_patterns['presets'][data_type].nil?
          CLI.log("No presets were found for #{data_type}. Skipping to next.")
          selected_presets[data_type] = nil
        else
          preset_selector.select(data_type)
        end
        CLI.put_footer
        pattern || { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
      end

      def preset_selector
        @preset_selector ||= PresetSelector.new(url: @url, payload: @payload)
      end

      def save_selected_presets(selected_presets)
        current_content = File.read(NewsScraper.configuration.scrape_patterns_filepath).chomp
        new_content = "#{current_content}\n#{build_domain_yaml(selected_presets)}\n"

        File.write(NewsScraper.configuration.scrape_patterns_filepath, new_content)
        CLI.log("Successfully wrote presets for #{@root_domain} to"\
          " #{NewsScraper.configuration.scrape_patterns_filepath}.")
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
    end
  end
end
