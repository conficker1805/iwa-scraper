class Crawler
  class << self
    ORIGIN_SITE = "https://news.ycombinator.com/"

    def parse(html)
      @data = Nokogiri::HTML.parse(html)

      result = posts.map do |post|
        if post.cached?
          path = Rails.root.join('tmp', "#{post.id}.yml")
          YAML.load_file(path)
        else
          post
        end

      end

      FetchPostJob.perform_later post_attrs.select { |p| p[:content].nil? }

      result
    rescue StandardError => e
      Rails.logger.info("DEBUG:------------------ #{ e.inspect } ------------------")
      # TODO: rescue parse error & send mail to admin
    end

    private

    def posts
      @_posts ||= post_attrs.map{ |p| Post.new(p) }
    end

    def post_attrs
      @_post_attrs ||= posts_wrap.map do |post|
        {
          id: Digest::MD5.hexdigest(url(post)),
          url: url(post),
          title: title(post),
          site: site(post),
          point: point(post),
          author: author(post),
          comment_count: comment_count(post),
          posted_at: posted_at(post)
        }
      end
    end

    def posts_wrap
      @data.css('.athing')
    end

    def url(post)
      url = post.css('.storylink').attr('href').to_s
      url = ORIGIN_SITE + url if (url =~ URI.regexp).nil?
      url
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
