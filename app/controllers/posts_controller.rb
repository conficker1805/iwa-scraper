class PostsController < ApplicationController
  include ActionController::Live

  def index
    return not_found if request.format != :js || page.to_i < 1

    cache = $redis.lrange("page:#{page}", 0, -1)
    @posts = cache.present? ? from_cache(cache) : Crawler.fetch_post(page)
  rescue Errno::ENOENT => e
    $redis.del("page:#{page}") && retry if cache.present?
  end

  def show
    @post = Post.new(id: id).load_cache
  rescue Errno::ENOENT => e
  end

  def images
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream)

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

  private

  def from_cache(cache)
    cache.map{ |id| Post.new(id: id).load_cache }
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
