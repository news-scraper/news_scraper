module NewsScraper
  module Trainer
    class PresetSelector
      PROVIDER_PHRASE = 'I will provide a pattern using'.freeze

      def initialize(data_type:, data_type_presets:, uri:, payload:, automated: false)
        @uri = uri
        @payload = payload
        @data_type_presets = data_type_presets
        @data_type = data_type
        @automated = automated
      end

      def select
        return unless @data_type_presets
        return best_pattern_option if @automated

        selected_option = CLI.prompt_with_options(
          "Select which preset to use for #{@data_type}:",
          pattern_options.keys
        )

        if selected_option.start_with?(PROVIDER_PHRASE)
          pattern_type = pattern_options[selected_option]
          return {
            'method' => pattern_type,
            'pattern' => CLI.get_input("Provide the #{pattern_type} pattern:")
          }
        end
        return if selected_option == 'skip'

        selected_index = pattern_options[selected_option]
        selected_preset_code = transform_results.to_a[selected_index].first
        @data_type_presets[selected_preset_code]
      end

      private

      def pattern_options
        return {} unless @data_type_presets

        @pattern_options ||= begin
          temp_options = transform_results.to_a.each_with_object({}).with_index do |(results, options_hash), index|
            preset_name = "#{results[0]}_#{@data_type}"
            extracted_text = results[1]
            options_hash["#{preset_name}: #{extracted_text}"] = index
          end
          %w(xpath css).each do |pattern_provider|
            temp_options["#{PROVIDER_PHRASE} #{pattern_provider}"] = pattern_provider
          end
          temp_options.merge('skip' => 'skip')
        end
      end

      def best_pattern_option
        case @data_type.to_sym
        when :body
          'readability' # default to readability for body
        when :title
          'html' # default to HTML for titles
        else
          # default to the longest value
          results = transform_results.max_by { |_, v| v.length }
          return unless results && !results.empty?
          results.first
        end
      end

      def transform_results
        return {} unless @data_type_presets

        scrape_details = blank_scrape_details
        @results ||= @data_type_presets.each_with_object({}) do |(preset_name, preset_details), hash|
          scrape_details[@data_type] = preset_details
          train_transformer = Transformers::Article.new(
            uri: @uri,
            payload: @payload,
            scrape_details: scrape_details,
          )

          transformed_result = train_transformer.transform[@data_type.to_sym]
          hash[preset_name] = transformed_result if transformed_result && !transformed_result.empty?
        end
      end

      def blank_scrape_details
        @blank_scrape_details ||= Constants::SCRAPE_PATTERNS.each_with_object({}) do |data_type, hash|
          hash[data_type] = nil
        end
      end
    end
  end
end
