# NewsScraper

### Simple ETL news scraper in Ruby

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

`NewsScraper::Scraper#scrape` will allow either yields the transformed data or returns an array of the transformed data for all Google News RSS articles for a query.

It takes in 1 parameter `:query`.

Array notation
```
article_hashes = NewsScraper::Scraper.new(query: 'Shopify').scrape # [ { author: ... }, { author: ... } ... ]
```

Block notation
```
NewsScraper::Scraper.new(query: 'Shopify').scrape do |article_hash|
  # { author: ... }
end
```

How the `Scraper` extracts and parses for the information is determined by scrape patterns (see **Scrape Patterns**).

### Transformed Data

Calling `NewsScraper::Scraper#scrape` with either the array or block notation will yield `transformed_data` hashes. [`article_scrape_patterns.yml`](https://github.com/richardwu/news_scraper/blob/master/config/article_scrape_patterns.yml) defines the data types that will be scraped for.

In addition, the `uri` and `root_domain`(hostname) of the article will be returned in the hash too.

Example
```
{
  author: 'Linus Torvald',
  body: 'The Linux kernel developed by Linus Torvald has become the backbone of most electronic devices we use to-date. It powers mobile phones, laptops, embedded devices, and even rockets...',
  description: 'The Linux kernel is one of the most important contributions to the world of technology.',
  keywords: 'linux,kernel,linus,torvald',
  section: 'technology',
  datetime: '1991-10-05T12:00:00+00:00',
  title: 'Linus Linux',
  uri: 'linusworld.com/the-linux-kernel',
  root_domain: 'linusworld.com'
}
```

### Scrape Patterns

Extracting each `:data_type` (see Example under **Transformed Data**) requires a grep pattern. A few `:presets` are specified in [`article_scrape_patterns.yml`](https://github.com/richardwu/news_scraper/blob/master/config/article_scrape_patterns.yml).

Since each news site (identified with `:root_domain`) uses a different markup, scrape patterns are defined on a per-`:root_domain` basis.

Specifying scrape patterns for additional (undefined) `:root_domains` is called training (see **Training**).

### Training

For each `:root_domain`, it is necesary to specify a grep/scrape pattern for each of the `:data_type`s. A rake task was written to provide a CLI for appending new `:root_domain`s using `:preset` scrape patterns.

Simply run
```
bundle exec rake scraper:train QUERY=<query>
```

where the CLI will step through the articles and `:root_domain`s of the articles relevant to `<query>`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/richardwu/news_scraper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

