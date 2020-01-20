require 'rails_helper'

describe FetchPostJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:url) { "https://techcrunch.com/2020/01/17/digitalocean-layoffs/" }
    let(:hashes) { [{url: url}]}

    it 'should add to queue' do
      expect { FetchPostJob.perform_later([]) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'should return workers' do
      VCR.use_cassette("posts/details") do
        threads = FetchPostJob.new.perform(hashes)
        expect(threads.count).to eq 5
      end
    end
  end

  describe '#update_post' do
    let(:url) { "https://techcrunch.com/2020/01/17/digitalocean-layoffs/" }

    it 'should return updated post' do
      VCR.use_cassette("posts/details") do
        html = Net::HTTP.get_response(URI(url)).body

        klass = FetchPostJob.new
        post = klass.send(:update_post, Post.new, html)
        expect(post.cover.start_with?("https://techcrunch.com")).to be_truthy
        expect(post.content.present?).to be_truthy
        expect(post.cached_at.present?).to be_truthy
      end
    end
  end
end
