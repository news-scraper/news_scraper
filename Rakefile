require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

require 'news_scraper'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

namespace :scraper do
  desc 'CLI that steps through articles for a given query and displays preset scrape pattern results; parameters: QUERY'
  task :train do
    raise "QUERY param not given.\n\tUsage: bundle exec rake scraper:train QUERY=<query>" unless ENV['QUERY']
    NewsScraper::Trainer.train(query: ENV['QUERY'])
  end
end

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb", "lib/**/*.rb")
  rdoc.rdoc_dir = "doc"
end