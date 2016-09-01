module NewsScraper
  module Trainer
    class Preset
      PROVIDER_PHRASE = 'I will provide a pattern using'

      def initialize(uri:, scrape_patterns:, payload:, data_type_presets:, data_type:)
        @uri = uri
        @scrape_patterns = scrape_patterns
        @payload = payload
        @data_type_presets = data_type_presets
        @data_type = data_type
      end

      def select
        selected_option = CLI.prompt_with_options(
          "Select which preset to use for #{@data_type}:",
          options.keys
        )

        if selected_option.start_with?(PROVIDER_PHRASE)
          pattern_type = options[selected_option]
          return {
            'method' => pattern_type,
            'pattern' => CLI.get_input("Provide the #{pattern_type} pattern:")
          }
        end
        return if selected_option == 'skip'

        selected_index = options[selected_option]
        selected_preset_code = transform_results[selected_index].first
        @data_type_presets[selected_preset_code]
      end

      private

      def options
        return @options if @options

        @options = transform_results.each_with_object({}).with_index do |(results, options_hash), index|
          preset_name = "#{results[0]}_#{@data_type}"
          extracted_text = results[1]
          options_hash["#{preset_name}: #{extracted_text}"] = index
        end
        %w(xpath css).each do |pattern_provider|
          @options["#{PROVIDER_PHRASE} #{pattern_provider}"] = pattern_provider
        end
        @options['skip'] = 'skip'
        @options
      end

      def transform_results
        return @results if @results
        return {} unless @data_type_presets

        scrape_details = blank_scrape_details
        @results = @data_type_presets.each_with_object({}) do |(preset_name, preset_details), hash|
          scrape_details[@data_type] = preset_details
          train_transformer = Transformers::Article.new(
            uri: @uri,
            payload: @payload,
            scrape_details: scrape_details,
            scrape_patterns: @scrape_patterns
          )

          hash[preset_name] = train_transformer.transform[@data_type.to_sym]
        end.to_a
      end

      def blank_scrape_details
        @scrape_patterns['data_types'].each_with_object({}) do |data_type, hash|
          hash[data_type] = nil
        end
      end
    end
  end
end
