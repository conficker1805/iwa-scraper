class PostsController < ApplicationController
  def index
    uri  = URI("https://news.ycombinator.com/best?p=#{page}")
    html = Net::HTTP.get(uri) # TODO: Handle if HTTP error

    @posts = Crawler.parse(html)
  end
end
