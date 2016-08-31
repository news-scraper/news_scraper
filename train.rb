#!/usr/bin/env ruby
#
require "bundler/setup"
require "news_scraper"
require 'pry'

NewsScraper.train(query: ARGV[0])
