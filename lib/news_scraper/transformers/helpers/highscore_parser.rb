require 'metainspector'
require 'highscore'
require 'readability'

module NewsScraper
  module Transformers
    module Helpers
      class HighScoreParser
        class << self
          # <code>NewsScraper::Transformers::Helpers::HighScoreParser.keywords</code> parses out keywords
          #
          # *Params*
          # - <code>url:</code>: keyword for the url to parse to a uri
          # - <code>payload:</code>: keyword for the payload from a request to the url (html body)
          #
          # *Returns*
          # - <code>keywords</code>: Top 5 keywords from the body of text
          #
          def keywords(url:, payload:)
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
            text.keywords.top(5).collect(&:text).join(',')
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
