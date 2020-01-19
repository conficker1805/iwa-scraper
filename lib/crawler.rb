class Crawler
  class << self
    ORIGIN_SITE = "https://news.ycombinator.com"
    NEWS_POST_PER_PAGE = 30

    def fetch_post(page)
      last_post  = page.to_i * Post::PER_PAGE
      first_post = last_post - Post::PER_PAGE + 1
      post_range = (first_post..last_post).to_a
      pages = [first_post, last_post].map{ |n| (n.to_f / NEWS_POST_PER_PAGE).ceil }.uniq

      html = pages.map do |crawl_page|
        uri = URI("#{ORIGIN_SITE}/best?p=#{crawl_page}")
        Net::HTTP.get(uri)
      end

      @data = Nokogiri::HTML.parse(html.join)

      hashes = post_attrs.select { |i| post_range.include? i[:rank] }
      result = hashes.map do |hash|
        $redis.rpush("page:#{page}", hash[:id])

        post = Post.new(hash)
        post.cached? ? post.load_cache : post
      end

      $redis.expire("page:#{page}", 5.minutes.to_i)

      FetchPostJob.perform_later hashes

      result
    rescue StandardError => e
      Rails.logger.info("DEBUG:------------------ #{ e.inspect } ------------------")
      # TODO: rescue parse error & send mail to admin
    end

    private

    def post_attrs
      @_post_attrs ||= posts_wrap.map do |post|
        {
          id: Digest::MD5.hexdigest(url(post)),
          url: url(post),
          title: title(post),
          rank: rank(post),
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

    def rank(post)
      post.css('.rank').text.to_i
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
