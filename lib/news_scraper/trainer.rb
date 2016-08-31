require 'yaml'

module NewsScraper
  class Trainer
    SEPARATOR = "\n------------------------------".freeze

    def initialize(query:)
      @article_uris = Extractors::GoogleNewsRss.new(query: query).extract
    end

    def train
      @article_uris.each do |uri|
        train_for_uri(uri)
      end
    end

    private

    def train_for_uri(uri)
      raw_html = Extractors::Article.new(uri: uri).extract

      transformer = Transformers::Article.new(uri: uri, payload: raw_html)

      begin
        transformed_resp = transformer.transform
      rescue NewsScraper::Transformers::ScrapePatternNotDefined => e
        $stdout.puts SEPARATOR
        $stdout.puts "There is no scrape pattern defined for #{e.root_domain} in config/article_scrape_patterns.yml"
        print "Step through presets for #{e.root_domain}? (y/n) "
        if $stdin.gets.chomp == 'y'
          all_presets = reloaded_presets
          selected_presets = train_all_data_types(uri, raw_html, all_presets)

          $stdout.puts SEPARATOR
          $stdout.puts selected_presets.to_yaml
          print "\nSave these scrape patterns for #{e.root_domain}? (y/n) "
          if $stdin.gets.chomp == 'y'
            save_selected_presets(e.root_domain, selected_presets)
          end
        else
          # TODO: Log ignored step-through for root_domain
        end
      end
    end

    def reloaded_presets
      YAML.load_file('config/article_scrape_patterns.yml')['presets']
    end

    def data_types
      Transformers::Article::DATA_TYPES
    end

    def blank_scrape_details
      data_types.each_with_object({}) do |data_type, hash|
          hash[data_type] = nil
      end
    end

    def train_all_data_types(uri, payload, all_presets)
      selected_presets = {}

      data_types.each do |target_data_type|
        data_type_presets = all_presets[target_data_type]
        preset_results = data_type_preset_results(
          uri,
          payload,
          data_type_presets,
          target_data_type
        ).to_a

        if preset_results.empty?
          $stdout.puts "\nNo presets were found for #{target_data_type}. Skipping to next."
        else
          $stdout.puts "\nSelect which preset to use:\n"
          preset_results.each.with_index(1) do |results, index|
            preset_name = "#{results[0]}_#{target_data_type}"
            extracted_text = results[1]
            $stdout.puts "#{index}) #{preset_name}: #{extracted_text}"
          end

          print "\n(#{(1..preset_results.size).to_a.join('/')}/[s]kip):"

          selected_preset_i = $stdin.gets.chomp.to_i

          if selected_preset_i >= 1 && selected_preset_i <= preset_results.size
            selected_preset_code = preset_results[selected_preset_i - 1][0]
            selected_preset_details = data_type_presets[selected_preset_code]
            selected_presets[target_data_type] = selected_preset_details
          end
        end

        selected_presets[target_data_type] ||= { 'method' => "<<<<< TODO >>>>>", 'pattern' => "<<<<< TODO >>>>>" }
      end

      selected_presets
    end

    def data_type_preset_results(uri, payload, presets, data_type)
      return {} unless presets

      scrape_details = blank_scrape_details

      options_for_data_type = presets.each_with_object({}) do |(preset_name, preset_details), hash|
        scrape_details[data_type] = preset_details
        train_transformer = Transformers::Article.new(
          uri: uri,
          payload: payload,
          scrape_details: scrape_details
        )

        hash[preset_name] = train_transformer.transform[data_type.to_sym]
      end
    end

    def save_selected_presets(root_domain, selected_presets)
      article_scrape_patterns = YAML.load_file('config/article_scrape_patterns.yml')

      save_domain_presets = if article_scrape_patterns['domains'].key?(root_domain)
        $stdout.puts "\nYAML file already contains scrape pattern for #{root_domain}:"
        $stdout.puts article_scrape_patterns['domains'][root_domain].to_yaml
        print "Overwrite? (y/n) "
        $stdin.gets.chomp == 'y'
      else
        true
      end

      if save_domain_presets
        article_scrape_patterns['domains'][root_domain] = selected_presets
        File.write('config/article_scrape_patterns.yml', article_scrape_patterns.to_yaml)
        $stdout.puts "\nSuccessfully wrote presets for #{root_domain} to config/article_scrape_patterns.yml."
      else
        $stdout.puts "\nDid not write presets for #{root_domain} to file."
      end

      $stdout.puts SEPARATOR
    end
  end
end
