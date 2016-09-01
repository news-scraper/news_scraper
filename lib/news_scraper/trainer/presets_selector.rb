module NewsScraper
  module Trainer
    class PresetsSelector
      def initialize(uri:)
        uri_parser = URIParser.new(uri)
        @uri = uri_parser.without_scheme
        @scrape_patterns = YAML.load_file(Constants::SCRAPE_PATTERN_FILEPATH)
      end

      def select(payload)
        selected_presets = {}

        CLI.put_header(@uri)
        CLI.log "Fetching information..."
        CLI.put_footer

        @scrape_patterns['data_types'].each do |target_data_type|
          data_type_presets = @scrape_patterns['presets'][target_data_type]
          preset_results = preset_results(payload, data_type_presets, target_data_type)

          CLI.put_header("Determining information for #{target_data_type}")
          if preset_results.empty?
            CLI.log("No presets were found for #{target_data_type}. Skipping to next.")
          else
            selected_preset = select_preset(preset_results, data_type_presets, target_data_type)
            selected_presets[target_data_type] = selected_preset if selected_preset
          end
          CLI.put_footer

          selected_presets[target_data_type] ||= { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
        end

        selected_presets
      end

      def preset_results(payload, presets, data_type)
        return {} unless presets

        scrape_details = blank_scrape_details
        presets.each_with_object({}) do |(preset_name, preset_details), hash|
          scrape_details[data_type] = preset_details
          train_transformer = Transformers::Article.new(
            uri: @uri,
            payload: payload,
            scrape_details: scrape_details,
            scrape_patterns: @scrape_patterns
          )

          hash[preset_name] = train_transformer.transform[data_type.to_sym]
        end.to_a
      end

      def blank_scrape_details
        @scrape_patterns['data_types'].each_with_object({}) do |data_type, hash|
          hash[data_type] = nil
        end
      end

      def select_preset(preset_results, data_type_presets, target_data_type)
        options = preset_results.each_with_object({}).with_index do |(results, options_hash), index|
          preset_name = "#{results[0]}_#{target_data_type}"
          extracted_text = results[1]
          options_hash["#{preset_name}: #{extracted_text}"] = index
        end
        %w(xpath css).each do |pattern_provider|
          options["I will provide a pattern using #{pattern_provider}"] = pattern_provider
        end
        options['skip'] = 'skip'

        selected_option = CLI.prompt_with_options(
          "Select which preset to use for #{target_data_type}:",
          options.keys
        )

        if selected_option.start_with?('I will provide a pattern using')
          pattern_type = options[selected_option]
          return {
            'method' => pattern_type,
            'pattern' => CLI.get_input("Provide the #{pattern_type} pattern:")
          }
        end
        return if selected_option == 'skip'

        selected_preset_code = preset_results[options[selected_option]].first
        data_type_presets[selected_preset_code]
      end
    end
  end
end
