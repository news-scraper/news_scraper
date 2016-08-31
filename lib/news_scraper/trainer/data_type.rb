module NewsScraper
  module Trainer
    module DataType
      extend self

      def train(uri, payload)
        selected_presets = {}
        all_presets = Transformers::Article.scrape_patterns['presets']

        NewsScraper::CLI.put_header(uri)
        NewsScraper::CLI.log "Fetching information..."
        NewsScraper::CLI.put_footer

        data_types.each do |target_data_type|
          data_type_presets = all_presets[target_data_type]
          preset_results = preset_results(uri, payload, data_type_presets, target_data_type)

          NewsScraper::CLI.put_header("Determining information for #{target_data_type}")
          if preset_results.empty?
            NewsScraper::CLI.log("No presets were found for #{target_data_type}. Skipping to next.")
          else
            selected_preset = select_preset(preset_results, data_type_presets, target_data_type)
            selected_presets[target_data_type] = selected_preset if selected_preset
          end
          NewsScraper::CLI.put_footer

          selected_presets[target_data_type] ||= { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
        end

        selected_presets
      end

      def preset_results(uri, payload, presets, data_type)
        return {} unless presets

        scrape_details = blank_scrape_details
        presets.each_with_object({}) do |(preset_name, preset_details), hash|
          scrape_details[data_type] = preset_details
          train_transformer = Transformers::Article.new(
            uri: uri,
            payload: payload,
            scrape_details: scrape_details
          )

          hash[preset_name] = train_transformer.transform[data_type.to_sym]
        end.to_a
      end

      def blank_scrape_details
        data_types.each_with_object({}) do |data_type, hash|
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

        selected_option = NewsScraper::CLI.prompt_with_options(
          "Select which preset to use for #{target_data_type}:",
          options.keys
        )

        if selected_option.start_with?('I will provide a pattern using')
          pattern_type = options[selected_option]
          return {
            'method' => pattern_type,
            'pattern' => NewsScraper::CLI.get_input("Provide the #{pattern_type} pattern:")
          }
        end
        return if selected_option == 'skip'

        selected_preset_code = preset_results[options[selected_option]].first
        data_type_presets[selected_preset_code]
      end

      def data_types
        NewsScraper::Transformers::Article.data_types
      end
    end
  end
end
