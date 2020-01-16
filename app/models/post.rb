class Post
  include ActiveModel::Model

  attr_accessor :id, :url, :title, :content, :cover, :site, :point, :author, :comment_count, :posted_at
end
