class Crawler
  class << self
    def parse(html)
      @data = Nokogiri::HTML.parse(html)

      posts.each do |post|
        if false # cache.present?
          load_cache
        end
      end

      # FetchPostJob.perform_later posts.select { |p| p.content.nil? }
      posts
    rescue StandardError => e
      # TODO: rescue parse error & send mail to admin
    end

    private

    def posts
      posts_wrap.map do |post|
        Post.new({
          id: Digest::MD5.hexdigest(url(post)),
          url: url(post),
          title: title(post),
          site: site(post),
          point: point(post),
          author: author(post),
          comment_count: comment_count(post),
          posted_at: posted_at(post)
        })
      end
    end

    def posts_wrap
      @data.css('.athing')
    end

    def url(post)
      post.css('.storylink').attr('href').to_s
    end

    def title(post)
      post.css('.title .storylink').text
    end

    def site(post)
      post.css('.title .sitestr').text
    end

    def point(post)
      post_info(post).css('.score').text
    end

    def author(post)
      post_info(post).css('.hnuser').text
    end

    def comment_count(post)
      post_info(post).css('a').last.text
    end

    def posted_at(post)
      post_info(post).css('.age a').text
    end

    def post_info(post)
      post.next_element.css('.subtext')
    end
  end
end
