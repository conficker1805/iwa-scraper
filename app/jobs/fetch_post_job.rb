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
          cache_path = Rails.root.join('tmp', 'posts', "#{post.id}.yml")

          next if File.exist?(cache_path)

          html = Net::HTTP.get(follow_redirection(post.url))

          images = Readability::Document.new(html, tags: %w[div p img a meta], attributes: %w[src href content]).images
          og_image =  Nokogiri::HTML(html).xpath('//meta[@property="og:image"]/@content')&.first&.value

          post.cover = images.first || og_image || default_image
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

  def follow_redirection(url)
    r = Net::HTTP.get_response(URI(url))

    until r['location'].nil?
      r = Net::HTTP.get_response(URI(r['location']))
    end

    r.uri
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
