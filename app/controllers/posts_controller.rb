class PostsController < ApplicationController
  include ActionController::Live

  def index
    # TODO: accept js only

    # Cache list of post in page

    no_cache = true

    if no_cache
      @posts = Crawler.fetch_post(page)

      # $redis.setex("page:#{page}", 5.minutes.seconds.to_i, 1)
    else

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

      sleep(0.1)
    end

    sse.close
  end
end
