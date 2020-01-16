class FetchPostJob < ApplicationJob
  queue_as :default

  def perform(posts)
    # TODO: 2 Job same time?
    posts.each do |hash|
      post = Post.new(hash)
      html = Net::HTTP.get(URI(post.url)) # TODO: Handle if HTTP error

      images = Readability::Document.new(html, tags: %w[div p img a], attributes: %w[src href]).images

      post.cover = images.first
      # TODO: if can't find => get img outside
      post.content = Readability::Document.new(html).content

      File.open(Rails.root.join('tmp', "#{post.id}.yml"), "w+") do |file|
        file.write(post.to_yaml)
        file.close
      end
    end
  end
end
