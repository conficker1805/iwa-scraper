class Crawler
  class << self
    def parse(html)
      @data = Nokogiri::HTML.parse(html)

      posts = posts_wrap.map do |post|
        Post.new({
          id: Digest::MD5.hexdigest(url(post)),
          url: url(post),
          title: title(post),
          site: site(post),
          point: point(post),
          author: author(post),
          posted_at: posted_at(post)
        })
      end

      # TODO: rescue parse error & send mail to admin
    end

    private

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

    def posted_at(post)
      post_info(post).css('a').last.text
    end

    def post_info(post)
      post.next_element.css('.subtext')
    end
  end
end
