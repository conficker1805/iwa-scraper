class Post
  include ActiveModel::Model

  attr_accessor :id, :url, :title, :cover, :site, :point, :author, :posted_at
end
