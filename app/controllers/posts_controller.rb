class PostsController < ApplicationController
  include ActionController::Live

  def index
    # TODO: accept js only
    cache = $redis.lrange("page:#{page}", 0, -1)

    if cache.present?
      @posts = cache.map{ |id| Post.new(id: id).load_cache }
    else
      @posts = Crawler.fetch_post(page)
    end
  rescue Errno::ENOENT => e
    if cache.present?
      $redis.del("page:#{page}")
      retry
    end
  end

  def images
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream)

    # Handle if data wrong format
    pending  = params[:post_ids].split(',')
    finished = []

    max = Time.now + 10.seconds

    until max < Time.now
      (pending - finished).each do |id|
        path = Rails.root.join('tmp', 'posts', "#{id}.yml")
        next unless File.exist?(path)
        post = YAML.load_file(path)

        if post.is_a?(Post)
          sse.write({id: id, cover: post.cover}, event: "fetch_image")
          finished << id
        end
      end

      sleep(0.5)
    end

    sse.close
  end
end
