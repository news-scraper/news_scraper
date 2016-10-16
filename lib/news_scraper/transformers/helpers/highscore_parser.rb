require 'metainspector'
require 'highscore'

module NewsScraper
  module Transformers
    module Helpers
      class HighScoreParser
        class << self
          def parse(url:, payload:)
            blacklist = Highscore::Blacklist.load(stopwords(url, payload))
            content = Readability::Document.new(payload, emove_empty_nodes: true, tags: [], attributes: []).content
            highscore(content, blacklist)
          end

          private

          def highscore(content, blacklist)
            text = Highscore::Content.new(content, blacklist)
            text.configure do
              set :multiplier, 2
              set :upper_case, 3
              set :long_words, 2
              set :long_words_threshold, 15
              set :ignore_case, true
            end
            text.keywords.top(5).collect(&:text)
          end

          def stopwords(url, payload)
            page = MetaInspector.new(url, document: payload)
            stopwords = NewsScraper.configuration.stopwords
            # Add the site name to the stop words
            stopwords += page.meta['og:site_name'].downcase.split(' ') if page.meta['og:site_name']
            stopwords
          end
        end
      end
    end
  end
end
