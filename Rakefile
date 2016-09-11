require 'bundler/gem_tasks'
require 'rake/testtask'

require 'news_scraper'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

namespace :scraper do
  desc 'CLI that steps through articles for a given query and displays preset scrape pattern results; parameters: QUERY'
  task :train do
    query = ENV['QUERY'] || ''
    NewsScraper::Trainer.train(query: query)
  end
end
