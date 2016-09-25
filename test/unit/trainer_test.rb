require 'test_helper'

module NewsScraper
  class TrainerTest < Minitest::Test
    def test_trainer
      url = 'https://google.ca'
      Extractors::GoogleNewsRss.expects(:new).with(query: 'stuff').returns(OpenStruct.new(extract: [url]))
      Trainer::UrlTrainer.expects(:new).with(url).returns(OpenStruct.new)
      Trainer.train(query: 'stuff')
    end
  end
end
