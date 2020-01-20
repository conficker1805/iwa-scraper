require 'rails_helper'

describe Post do
  describe 'constance & attributes' do
    it 'should return number of post per page' do
      expect(Post::PER_PAGE).to eq 12
    end

    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }
    let(:attrs) { [:id, :url, :title, :content, :rank, :cover, :site, :point, :author, :comment_count, :posted_at, :cached_at] }

    it 'should have attributes' do
      attrs.each do |i|
        expect(post.respond_to?(i)).to be_truthy
        expect(post.respond_to?("#{i}=")).to be_truthy
      end
    end
  end

  describe '#cached?' do
    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

    context 'no cache found' do
      it 'should return false' do
        expect(post.cached?).to be_falsey
      end
    end

    context 'found cache file' do
      before { FileUtils.touch post.cache_path }
      after { File.delete(post.cache_path) }

      it 'should return true' do
        expect(post.cached?).to be_truthy
      end
    end
  end

  describe '#load_cache' do
    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

    context 'no cache file' do
      it 'should return false' do
        expect { post.load_cache }.to raise_error(Errno::ENOENT)
      end
    end

    context 'cache file is exists' do
      before do
        File.open(post.cache_path, "w+") do |file|
          file.write(post.to_yaml)
          file.close
        end
      end

      after { File.delete(post.cache_path) }

      it 'should return post' do
        expect(post.load_cache.is_a?(Post)).to be_truthy
      end
    end
  end

  describe '#cache_path' do
    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

    it 'should return cache path as string' do
      expect(post.cache_path.to_s).to eq "#{Rails.root}/tmp/posts/#{post.id}.yml"
    end
  end
end
