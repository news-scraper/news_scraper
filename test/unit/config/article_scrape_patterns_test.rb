require 'test_helper'

class ArticleScrapePatternsTest < Minitest::Test
  VALID_METHODS = %w(css xpath readability metainspector highscore).freeze

  def setup
    super
    @domains = NewsScraper.configuration.scrape_patterns['domains'].keys
  end

  def test_domains_should_specify_all_data_types
    data_types = NewsScraper.configuration.scrape_patterns['data_types']

    @domains.each do |domain|
      data_types.each do |dt|
        assert NewsScraper.configuration.scrape_patterns['domains'][domain].keys.include?(dt),
          "#{domain} did not include #{dt}"
      end
    end
  end

  def test_domains_should_specify_method_and_pattern_for_all_data_types
    @domains.each do |domain|
      NewsScraper.configuration.scrape_patterns['domains'][domain].each_pair do |data_type, spec|
        refute_nil spec, "Spec was nil for #{data_type} for domain #{domain}"
        assert spec.include?('method'),
          "Spec did not include method for #{data_type} for domain #{domain}, was #{spec}"
        assert spec.include?('pattern'),
          "Spec did not include pattern for #{data_type} for domain #{domain}, was #{spec}"
      end
    end
  end

  def test_scrape_methods_must_be_a_valid_method
    @domains.each do |domain|
      NewsScraper.configuration.scrape_patterns['domains'][domain].each_pair do |data_type, spec|
        assert VALID_METHODS.include?(spec['method']),
          "#{spec['method']} is not a supported scrape method for #{data_type} for #{domain}"\
          " Must be one of #{VALID_METHODS}"
      end
    end
  end

  def test_scrape_methods_presets_are_valid
    NewsScraper.configuration.scrape_patterns['presets'].each_pair do |data_type, presets|
      presets.each_pair do |preset_type, spec|
        assert VALID_METHODS.include?(spec['method']),
          "#{spec['method']} was not a valid method for #{preset_type} in #{data_type}. Must be one of #{VALID_METHODS}"
        refute_match(
          /(.*)[1]/,
          spec['pattern'],
          "Don't specify the first element in an xpath, this is done automatically for xpath."\
          " This was found for data_type=#{data_type}, preset=#{preset_type}"
        ) if spec['method'] == 'xpath'
      end
    end
  end

  def test_scrape_methods_have_proper_variable_names
    # This needs to load the file directly because it is testing the variable names that yaml parsing eats
    article_scrape_patterns = File.read(NewsScraper::Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH)
                                  .split("\n")
                                  .map(&:strip)

    NewsScraper.configuration.scrape_patterns['presets'].each_pair do |data_type, presets|
      # Find the first occurence of data_type:, then we search from there
      section_index = article_scrape_patterns.index("#{data_type}:")
      section_to_search = article_scrape_patterns[section_index..-1]
      presets.each_pair do |preset_type, _|
        # Find the first occurence of preset_type: since we started at the data_type:
        # This will always work as the YAML cannot be a valid hash if we have any duplicates
        # and we start our search from the beginning of this preset section
        actual_name = section_to_search.detect { |p| p.start_with?("#{preset_type}: ") }
        valid_variable_name = [preset_type, data_type].join('_')
        expected_name = "#{preset_type}: &#{valid_variable_name}"
        assert_equal expected_name, actual_name,
          "Did not include a proper variable name for #{preset_type} under #{data_type}."\
          " Should be #{expected_name}, was #{actual_name}"
      end
    end
  end

  def test_all_preset_xpaths_are_valid
    noko_html = Nokogiri::HTML(raw_data_fixture(@domains.first))

    NewsScraper.configuration.scrape_patterns['presets'].each_pair do |data_type, presets|
      presets.each_pair do |preset_type, spec|
        next unless spec['method'] == 'xpath'

        begin
          noko_html.xpath("(#{spec['pattern']})[1]")
        rescue => e
          flunk "#{spec['pattern']} was not valid for preset #{preset_type}"\
            " as an xpath for #{data_type}. (Error #{e})"
        end
      end
    end
  end

  def test_all_preset_css_paths_are_valid
    noko_html = Nokogiri::HTML(raw_data_fixture(@domains.first))

    NewsScraper.configuration.scrape_patterns['presets'].each_pair do |data_type, presets|
      presets.each_pair do |preset_type, spec|
        next unless spec['method'] == 'css'

        begin
          noko_html.css(spec['pattern'])
        rescue => e
          flunk "#{spec['pattern']} was not valid for preset #{preset_type}"\
            " as a css path for #{data_type}. (Error #{e})"
        end
      end
    end
  end
end
