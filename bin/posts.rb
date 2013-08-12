require_relative '../lib/reddit'

def fetch_posts(url, params = {})
  LOGGER.info("Requesting URL #{url} with params #{params.inspect}")

  response = HTTP.get(url, params)

  return response.body['data']
end

# Fuckit, take all the pages!
def each_page(url, pages = 100)
  after = nil

  pages.times do
    response = fetch_posts(url, :after => after)

    yield response['children']

    after = response['after'] if response['after']

    # For the sake of not hitting the rate limit too fast.
    sleep(0.1)
  end
end

def fetch_all_the_things
  url = "http://reddit.com/r/#{SUBREDDIT}.json"

  each_page(url) do |posts|
    posts.each { |post| yield post }
  end
end

fetch_all_the_things do |post|
  id = post['data']['name']

  unless post['data']['is_self']
    LOGGER.info("Skipping post #{id} as it's not a self post")

    next
  end

  if Post[:reddit_id => id]
    LOGGER.info("Skipping post #{id} as it has already been added")

    next
  else
    LOGGER.info("Creating row for post #{id}")
  end

  Post.create(
    :title     => post['data']['title'],
    :reddit_id => id,
    :subreddit => post['data']['subreddit'].downcase,
    :author    => post['data']['author'],
    :url       => post['data']['url'],
    :body      => post['data']['selftext'],
    :upvotes   => post['data']['ups'],
    :downvotes => post['data']['downs'],
    :comments  => post['data']['num_comments'],
    :posted_at => Time.at(post['data']['created_utc']).utc
  )
end
