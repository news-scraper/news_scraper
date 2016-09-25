module ExtractorsTestHelpers
  def stub_http_request(url:, body:)
    HTTParty.expects(:get).with(url, headers: { "User-Agent" => "news-scraper-#{NewsScraper::VERSION}" })
            .returns(stub(
              body: body,
              code: 200,
              message: 'OK'
            ))
  end
end
