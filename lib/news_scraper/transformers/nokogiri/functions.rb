require 'nokogiri'

module NewsScraper
  module Transformers
    module Nokogiri
      class Functions
        # Implements fn:string-join of XPath 2.0
        def string_join(nodeset, separator)
          nodeset.map(&:text).join(separator)
        end
        alias_method :'string-join', :string_join
      end
    end
  end
end
