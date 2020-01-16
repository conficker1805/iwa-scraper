class PostsController < ApplicationController
  def index
    uri  = URI("https://news.ycombinator.com/best?p=#{page}")
    html = Net::HTTP.get(uri) # TODO: Handle if HTTP error

    posts = Crawler.parse(html)
  end

  private

  def page
    params.fetch(:page, 1)
  end
end
