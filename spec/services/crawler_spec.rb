require 'rails_helper'

describe Crawler do
  describe '#fetch_post' do
    let(:page) { 1 }

    before do
      $redis.flushdb
      allow(FetchPostJob).to receive(:perform_later).and_return(nil)
    end

    it 'should fetch post base on page number' do
      VCR.use_cassette("hackernews") do
        posts = Crawler.fetch_post(1)

        expect(posts.count).to eq Post::PER_PAGE
        expect($redis.lrange("page:1", 0, -1).count).to eq Post::PER_PAGE
      end
    end
  end

  describe '#html_for' do
    it 'should return list of hash' do
      VCR.use_cassette("hackernews") do
        html = Crawler.send(:html_for, [1])
        data = Nokogiri::HTML.parse(html)
        expect(data.css('.athing').count).to eq 30
      end
    end
  end

  describe '#post_attrs' do
    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

    before do
      VCR.use_cassette("hackernews") do
        html = Crawler.send(:html_for, [1])
        @data = Nokogiri::HTML.parse(html).css('.athing')
      end

      allow(Crawler).to receive(:posts_wrap).and_return(@data)
    end

    it 'should return list of hash' do
      hashes = Crawler.send(:post_attrs)
      expect(hashes.count).to eq 30
    end
  end
end
