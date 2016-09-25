module NewsScraper
  module Trainer
    class PresetSelector
      PROVIDER_PHRASE = 'I will provide a pattern using'.freeze

      def initialize(url:, payload:)
        @url = url
        @payload = payload
      end

      def select(data_type)
        pattern_options = pattern_options(data_type)

        selected_option = CLI.prompt_with_options(
          "Select which preset to use for #{data_type}:",
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

        selected_preset_code = pattern_options[selected_option]
        result = transform_results[data_type][selected_preset_code].merge(
          'variable' => [selected_preset_code, data_type].join('_')
        )
        result.delete('data')
        result
      end

      private

      def pattern_options(data_type)
        # Add valid options from the transformed results
        options = transform_results[data_type].each_with_object({}) do |(option, details), valid_options|
          next unless details['data'] && !details['data'].empty?
          table_key = Terminal::Table.new do |t|
            t << ['method', details['method']]
            t << ['pattern', details['pattern']]
            t << ['data', details['data']]
          end
          valid_options["\n#{table_key}"] = option
        end

        # Add in options to customize the pattern
        %w(xpath css).each do |pattern_provider|
          options["#{PROVIDER_PHRASE} #{pattern_provider}"] = pattern_provider
        end

        # Add option in to skip
        options.merge('skip' => 'skip')
      end

      def transform_results
        @transform_results ||= Transformers::TrainerArticle.new(
          url: @url,
          payload: @payload
        ).transform
      end
    end
  end
end
