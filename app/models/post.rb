class Post
  include ActiveModel::Model

  attr_accessor :id, :url, :title, :content, :cover, :site, :point, :author, :comment_count, :posted_at

  def cached?
    File.exist?(Rails.root.join('tmp', "#{id}.yml"))
  end
end
