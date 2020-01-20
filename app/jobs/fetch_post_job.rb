class FetchPostJob < ApplicationJob
  sidekiq_options retry: false

  def perform(posts)
    @mutex = Mutex.new
    @posts = posts.map{ |hash| Post.new(hash) }

    create_workspace

    workers = (0...5).map do
      Thread.new do
        while post = next_post
          cache_path = Rails.root.join('tmp', 'posts', "#{post.id}.yml")

          next if File.exist?(cache_path)

          html = follow_redirection(post.url)
          post = update_post(post, html)

          File.open(cache_path, "w+") do |file|
            file.write(post.to_yaml)
            file.close
          end
        end
      end
    end

    workers.map(&:join)
  end

  def update_post(post, html)
    default_image = ActionController::Base.helpers.asset_url('default-post.png')
    images = Readability::Document.new(html, tags: %w[div p img a meta], attributes: %w[src href content]).images
    og_image =  Nokogiri::HTML(html).xpath('//meta[@property="og:image"]/@content')&.first&.value

    cover = images.first || og_image
    cover = URI.join(post.url, cover).to_s if cover && !URI(cover).absolute

    post.cover = cover || default_image
    post.content = Readability::Document.new(html).content
    post.cached_at = Time.now
    post
  end

  def follow_redirection(url)
    r = Net::HTTP.get_response(URI(url))

    until r['location'].nil?
      r = Net::HTTP.get_response(URI(r['location']))
    end

    r.body
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
