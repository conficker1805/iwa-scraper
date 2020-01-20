FactoryBot.define do
  factory :post do
    id { Digest::MD5.hexdigest('https://google.com') }
    url { 'https://google.com' }
    title { 'Google' }
    content { "<div><p>Search</p></div>" }
    sequence(:rank) { |n| n }
    cover { 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png' }
    site { 'https://google.com' }
    point { (150..600).to_a.sample }
    author { Faker::Name.name }
    comment_count { (1..500).to_a.sample }
    posted_at { (1..29).to_a.sample.to_s + 'days ago' }
    cached_at { 1.minute.ago }
  end
end
