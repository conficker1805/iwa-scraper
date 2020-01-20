require 'rails_helper'

describe PostsController, type: :controller do
  describe 'GET #index' do
    context 'call wrong format' do
      def do_request
        get :index, params: { page: 1 }
      end

      it 'should raise 404' do
        expect { do_request }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'all params are good' do
      def do_request
        get :index, params: { page: 1 }, format: :js
      end

      before { $redis.flushdb }

      context 'has cache' do
        before do

          5.times do
            post = Post.new(FactoryBot.attributes_for(:post))
            File.open(post.cache_path, "w+") do |file|
              file.write(post.to_yaml)
              file.close
            end

            $redis.rpush("page:1", post.id)
          end

          expect_any_instance_of(PostsController).to receive(:from_cache).and_return([Post.new])
        end

        after do
          directory = Rails.root.join('tmp', 'posts')
          FileUtils.rm_rf(directory)
          Dir.mkdir(directory)
        end

        it 'should call method load cache' do
          do_request
          expect(assigns[:posts].count).to eq 1
          expect(response).to render_template :index
        end
      end

      context 'no cache' do
        it 'Should call crawler to fetch posts' do
          expect(Crawler).to receive(:fetch_post)
          do_request
        end
      end
    end
  end

  describe 'GET #show' do
    context 'post is exist' do
      let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

      def do_request
        get :show, params: { id: post.id }
      end

      before do
        File.open(post.cache_path, "w+") do |file|
          file.write(post.to_yaml)
          file.close
        end
      end

      it 'should be render template :show' do
        do_request
        expect(assigns[:post].is_a? Post).to be_truthy
        expect(response).to render_template :show
      end
    end

    context 'post is invalid' do
      def do_request
        get :show, params: { id: 'invalidid' }
      end

      it 'should be raise error' do
        do_request
        expect(assigns[:post].nil?).to be_truthy
        expect(response).to render_template :show
      end
    end
  end

  describe 'GET #images' do
    let(:post) { Post.new(FactoryBot.attributes_for(:post)) }

    before do
      expect_any_instance_of(PostsController).to receive(:timeout).at_least(:once).and_return(2.seconds.from_now)

      File.open(post.cache_path, "w+") do |file|
        file.write(post.to_yaml)
        file.close
      end
    end

    subject { process :images, method: :get, params: { post_ids: "#{post.id}" } }

    it 'should return post details' do
      expect(subject.body.include?(post.id)).to be_truthy
      expect(subject.body.include?(post.cover)).to be_truthy
    end
  end
end
