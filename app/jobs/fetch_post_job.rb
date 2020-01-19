class FetchPostJob < ApplicationJob
  queue_as :default

  def perform(posts)
    @mutex = Mutex.new
    @posts = posts.map{ |hash| Post.new(hash) }
    default_image = ActionController::Base.helpers.asset_url('default-post.png')

    create_workspace

    workers = (0...5).map do
      Thread.new do
        while post = next_post
          cache_path = Rails.root.join('tmp', 'posts', "#{post.rank}.yml")

          next if File.exist?(cache_path)

          html = Net::HTTP.get(URI(post.url)) # TODO: Handle if HTTP error

          images = Readability::Document.new(html, tags: %w[div p img a], attributes: %w[src href]).images

          post.cover = images.first || default_image
          post.content = Readability::Document.new(html).content
          post.cached_at = Time.now

          File.open(cache_path, "w+") do |file|
            file.write(post.to_yaml)
            file.close
          end
        end
      end
    end

    workers.map(&:join)
  end

  def next_post
    post = nil

    @mutex.synchronize do
      post = @posts.shift
    end

    post
  end

  def create_workspace
    directory = Rails.root.join('tmp', 'posts')
    Dir.mkdir(directory) unless File.exists?(directory)
  end
end
