module NewsScraper
  module Transformers
    class TrainerArticle < Article
      # Initialize a TrainerArticle object
      #
      # *Params*
      # - <code>url</code>: keyword arg - the url on which scraping was done
      # - <code>payload</code>: keyword arg - the result of the scrape
      #
      def initialize(url:, payload:)
        super(url: url, payload: payload)
      end

      # Transform the article
      #
      # *Returns*
      # - <code>transformed_response</code>: tries all possible presets and returns a hash representing the results
      #
      def transform
        presets = NewsScraper.configuration.scrape_patterns['presets']
        transformed_response = presets.each_with_object({}) do |(data_type, preset_options), response|
          response[data_type] = preset_options.each_with_object({}) do |(option, scrape_details), data_type_options|
            data = parsed_data(scrape_details['method'].to_sym, scrape_details['pattern'])
            data_type_options[option] = scrape_details.merge('data' => data)
          end
        end
        transformed_response.merge('uri' => @uri, 'root_domain' => @root_domain)
      end
    end
  end
end
