# NewsScraper

### Simple ETL news scraper in Ruby

[RubyGems](https://rubygems.org/gems/news_scraper)

A collection of extractors, transformers and loaders for a variety of news feeds and outlets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'news_scraper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install news_scraper

## Usage

### Scraping

`NewsScraper::Scraper#scrape` will return an array of the transformed data for all Google News RSS articles for the given query.

Optionally, you can pass in a block and it will yield the transformed data on a per-article basis.

It takes in 1 parameter `query:`.

Array notation
```ruby
article_hashes = NewsScraper::Scraper.new(query: 'Shopify').scrape # [ { author: ... }, { author: ... } ... ]
```

*Note:* the array notation may raise `NewsScraper::Transformers::ScrapePatternNotDefined` (domain is not in the configuration) or `NewsScraper::ResponseError` (non-200 response), for this reason, it is suggested to use the block notation where this can be handled properly

Block notation
```ruby
NewsScraper::Scraper.new(query: 'Shopify').scrape do |a|
  case a.class.to_s
  when "NewsScraper::Transformers::ScrapePatternNotDefined"
    puts "#{a.root_domain} was not trained"
  when "NewsScraper::ResponseError"
    puts "#{a.url} returned an error: #{a.error_code}-#{a.message}"
  else
    # { author: ... }
  end
end
```

How the `Scraper` extracts and parses for the information is determined by scrape patterns (see **Scrape Patterns**).

### Transformed Data

Calling `NewsScraper::Scraper#scrape` with either the array or block notation will yield `transformed_data` hashes. [`article_scrape_patterns.yml`](https://github.com/news-scraper/news_scraper/blob/master/config/article_scrape_patterns.yml) defines the data types that will be scraped for.

In addition, the `url` and `root_domain`(hostname) of the article will be returned in the hash too.

Example
```ruby
{
  author: 'Linus Torvald',
  body: 'The Linux kernel developed by Linus Torvald has become the backbone of most electronic devices we use to-date. It powers mobile phones, laptops, embedded devices, and even rockets...',
  description: 'The Linux kernel is one of the most important contributions to the world of technology.',
  keywords: 'linux,kernel,linus,torvald',
  section: 'technology',
  datetime: '1991-10-05T12:00:00+00:00',
  title: 'Linus Linux',
  url: 'https://linusworld.com/the-linux-kernel',
  root_domain: 'linusworld.com'
}
```

### Scrape Patterns

Scrape patterns are xpath or CSS patterns used by Nokogiri to extract relevant HTML elements.

Extracting each `:data_type` (see Example under **Transformed Data**) requires a scrape pattern. A few `:presets` are specified in [`article_scrape_patterns.yml`](https://github.com/news-scraper/news_scraper/blob/master/config/article_scrape_patterns.yml).

Since each news site (identified with `:root_domain`) uses a different markup, scrape patterns are defined on a per-`:root_domain` basis.

Specifying scrape patterns for new, undefined `:root_domains` is called training (see **Training**).

#### Customizing Scrape Patterns

`NewsScraper.configuration` is the entry point for scrape patterns. By default, it loads the contents of [`article_scrape_patterns.yml`](https://github.com/news-scraper/news_scraper/blob/master/config/article_scrape_patterns.yml), but you can override this with the `fetch_method` which accepts a proc.

For example, to override the domains section we can do this like so:

```ruby
@default_configuration = NewsScraper.configuration.scrape_patterns.dup
NewsScraper.configure do |config|
  config.fetch_method = proc do
    @default_configuration['domains'] = { ... }
    @default_configuration
  end
end
```

Of course, using this method you can override any part of the configuration individually, or the entire thing. It is fully customizeable.

This helps with separate apps which may track domains training itself. If the configuration is not set correctly, a newly trained domain will not be in the configuration and a `NewsScraper::Transformers::ScrapePatternNotDefined` error will be raised.

It would be appreciated that any domains you train outside of this gem eventually end up as a pull request back to [`article_scrape_patterns.yml`](https://github.com/news-scraper/news_scraper/blob/master/config/article_scrape_patterns.yml).

### Training

For each `:root_domain`, it is neccesary to specify a scrape pattern for each of the `:data_type`s. A rake task was written to provide a CLI for appending new `:root_domain`s using `:preset` scrape patterns.

Simply run
```
bundle exec rake scraper:train QUERY=<query>
```

where the CLI will step through the articles and `:root_domain`s of the articles relevant to `<query>`.

Of course, this will simply create an entry for a `domain` with `domain_entries`, so as long as your application provides the same functionality, this can be overriden in your app. Just provide a domain entry like so:

```yaml
domains:
  root_domain.com:
    author:
      method: method
      pattern: pattern
    body:
      method: method
      pattern: pattern
    description:
      method: method
      pattern: pattern
    keywords:
      method: method
      pattern: pattern
    section:
      method: method
      pattern: pattern
    datetime:
      method: method
      pattern: pattern
    title:
      method: method
      pattern: pattern
```

The options using the presets in [`article_scrape_patterns.yml`](https://github.com/news-scraper/news_scraper/blob/master/config/article_scrape_patterns.yml), can be obtained using this snippet:
```ruby
include NewsScraper::ExtractorsHelpers
  
transformed_data = NewsScraper::Transformers::TrainerArticle.new(
  url: url,
  payload: http_request(url).body
).transform
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/news-scraper/news_scraper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

