class Post
  include ActiveModel::Model

  PER_PAGE = 12

  attr_accessor :id, :url, :title, :content, :rank, :cover, :site, :point, :author, :comment_count, :posted_at, :cached_at

  def cached?
    File.exist? cache_path
  end

  def load_cache
    YAML.load_file(cache_path)
  end

  def cache_path
    Rails.root.join('tmp', 'posts', "#{id}.yml")
  end
end
