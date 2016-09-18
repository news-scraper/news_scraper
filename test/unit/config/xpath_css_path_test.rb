require 'test_helper'

class XpathCssPathTest < Minitest::Test
  def setup
    @scrape_patterns = YAML.load_file(NewsScraper::Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH)
    @presets = @scrape_patterns['presets']
  end

  def test_author_class
    assert_matches_spec(
      spec: @presets['author']['class'],
      input_html: "<div class='author'>author_test</div>",
      expected_result: 'author_test'
    )
  end

  def test_author_id
    assert_matches_spec(
      spec: @presets['author']['id'],
      input_html: "<div id='author'>author_test</div>",
      expected_result: 'author_test'
    )
  end

  def test_author_name
    assert_matches_spec(
      spec: @presets['author']['name'],
      input_html: "<div class='author-name'>author_test</div>",
      expected_result: 'author_test'
    )
  end

  def test_author_link
    assert_matches_spec(
      spec: @presets['author']['link'],
      input_html: "<a href='http://yolo.com/author/bob'>author_test</a>",
      expected_result: 'author_test'
    )
  end

  def test_author_meta
    assert_matches_spec(
      spec: @presets['author']['meta'],
      input_html: "<meta name='author' content='author_test' />",
      expected_result: 'author_test'
    )
  end

  def test_author_rel_link
    assert_matches_spec(
      spec: @presets['author']['rel_link'],
      input_html: "<a rel='author'>author_test</a>",
      expected_result: 'author_test'
    )
  end

  def test_author_vcard
    assert_matches_spec(
      spec: @presets['author']['vcard'],
      input_html: "<div class='vcard'><div class='fn'>author_test</div></div>",
      expected_result: 'author_test'
    )
  end

  def test_description_meta
    assert_matches_spec(
      spec: @presets['description']['meta'],
      input_html: "<meta name='description' content='description_test' />",
      expected_result: 'description_test'
    )
  end

  def test_description_og
    assert_matches_spec(
      spec: @presets['description']['og'],
      input_html: "<meta property='og:description' content='description_test' />",
      expected_result: 'description_test'
    )
  end

  def test_keywords_meta
    assert_matches_spec(
      spec: @presets['keywords']['meta'],
      input_html: "<meta name='keywords' content='keywords_1, keywords_2' />",
      expected_result: 'keywords_1, keywords_2'
    )
  end

  def test_keywords_article_tag
    assert_matches_spec(
      spec: @presets['keywords']['article_tag'],
      input_html: "<meta property='article:tag' content='keywords_1, keywords_2' />",
      expected_result: 'keywords_1, keywords_2'
    )
  end

  def test_section_meta
    assert_matches_spec(
      spec: @presets['section']['meta'],
      input_html: "<meta property='article:section' content='section' />",
      expected_result: 'section'
    )
  end

  def test_datetime_article_date_original
    assert_matches_spec(
      spec: @presets['datetime']['article_date_original'],
      input_html: "<meta name='article_date_original' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_article_published_time
    assert_matches_spec(
      spec: @presets['datetime']['article_published_time'],
      input_html: "<meta property='article:published_time' content='11am' />",
      expected_result: '11am'
    )
  end

  def test_datetime_date
    assert_matches_spec(
      spec: @presets['datetime']['date'],
      input_html: "<meta name='date' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_date_published
    assert_matches_spec(
      spec: @presets['datetime']['date_published'],
      input_html: "<meta itemprop='datePublished' datetime='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_og_published_time
    assert_matches_spec(
      spec: @presets['datetime']['og_published_time'],
      input_html: "<meta property='og:published_time' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_original_publication_date
    assert_matches_spec(
      spec: @presets['datetime']['original_publication_date'],
      input_html: "<meta name='OriginalPublicationDate' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_publication_date
    assert_matches_spec(
      spec: @presets['datetime']['publication_date'],
      input_html: "<meta name='publication_date' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_publish_date
    assert_matches_spec(
      spec: @presets['datetime']['publish_date'],
      input_html: "<meta name='PublishDate' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_rnews_date_published
    assert_matches_spec(
      spec: @presets['datetime']['rnews_date_published'],
      input_html: "<meta property='rnews:datePublished' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_datetime_sailthru_date
    assert_matches_spec(
      spec: @presets['datetime']['sailthru_date'],
      input_html: "<meta name='sailthru.date' content='Sept 1, 2016' />",
      expected_result: 'Sept 1, 2016'
    )
  end

  def test_title_html
    assert_matches_spec(
      spec: @presets['title']['html'],
      input_html: "<head><title>title_test</title></head>",
      expected_result: 'title_test'
    )
  end

  def test_title_og
    assert_matches_spec(
      spec: @presets['title']['og'],
      input_html: "<meta property='og:title' content='title_test' />",
      expected_result: 'title_test'
    )
  end

  def assert_matches_spec(spec:, input_html:, expected_result:)
    noko_html = Nokogiri::HTML(input_html)
    pattern = spec['method'] == 'xpath' ? "(#{spec['pattern']})[1]" : spec['pattern']
    matches = noko_html.send(spec['method'], pattern)
    assert_equal 1, matches.length
    value = matches.first.children ? matches.first.children.text : matches.first.value
    assert_equal expected_result, value
  end
end
