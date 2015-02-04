# Also add these feeds (filter for ruby/rails & duplicates via yahoo pipes)
  # https://weworkremotely.com/categories/2/jobs.rss
  # https://www.wfh.io/jobs.atom
  # https://careers.stackoverflow.com/jobs/feed?searchTerm=ruby+rails&allowsremote=True
  # http://nomadjobs.io/remote-jobs.rss
# Simply Hired summaries aren't much good, perhaps ditch this and rely on only Indeed for AU jobs
# Some jobs listed as "remote" aren't really or are only partially remote...


# https://pipes.yahoo.com/pipes/pipe.run?_id=cd8049981ac18873c53649f279bd829e&_render=json

namespace :scraper do
  desc "Fetch jobs from indeed"
  task scrape_indeed: :environment do
    require 'open-uri'
    require 'json'

    # Set API token and URL
    publisher = ENV["INDEED_PUBLISHER_ID"]
    polling_url = "http://api.indeed.com/ads/apisearch"

    # Specify request parameters
    params = {
      publisher: publisher,
      format: JSON,
      q: 'title:ruby rails',
      co: 'AU',
      highlight: 0,
      limit: 100,
      v: 2
    }

    # Prepare API request
    uri = URI.parse(polling_url)
    uri.query = URI.encode_www_form(params)

    # Submit request
    result = JSON.parse(open(uri).read)

    # Store results in database
    result["results"].each do |result|

      # Create new Post
      @post = Post.new
      @post.jobtitle = result["jobtitle"]
      @post.company = result["company"]
      @post.city = result["city"]
      @post.state = result["state"]
      @post.location = result["formattedLocation"]
      @post.remote = "N"
      @post.date = result["date"]
      @post.snippet = result["snippet"]
      @post.url = result["url"]
      @post.jobkey = result["jobkey"]

      # Save Post
      @post.save
    end

  end

  desc "Fetch jobs from Stack Overflow"
  task scrape_stack: :environment do
    require 'feedjira'

    feed = Feedjira::Feed.fetch_and_parse("https://pipes.yahoo.com/pipes/pipe.run?_id=cd8049981ac18873c53649f279bd829e&_render=rss", {:ssl_verify_peer => false})
    entries = feed.entries

    # Store results in database
    entries.each do |entry|
      
      # Ruby / Rails Web Developer at Zearn (New York, NY) (allows remote)

      # Create new Post
      @post = Post.new
      @post.jobtitle = entry.title.sub(/\s\bat\s.+/ , '')
      # @post.company = (slice _at_company_)
      @post.remote = "Y"
      @post.url = entry.url
      @post.snippet = entry.summary
      @post.date = entry.published

      # Save Post
      @post.save
    end

  end

  desc "Destroy all posts"
  task destroy_all_posts: :environment do
    Post.destroy_all
  end

end
