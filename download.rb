require 'bundler/setup'

require 'simple_cache'
require 'feedzirra'
require 'fileutils'

OUTPUT_DIR = 'output'
CACHE_DIR = File.expand_path('~/Library/Caches/railscasts-download-cache')
FEED_URL = 'http://railscasts.com/subscriptions/6MT8ikJqpLaQxbZ9ICXKyw/episodes.rss'

cacher = SimpleCache::Cacher.new(CACHE_DIR)

puts 'Fetching the feed list ...'
# I do not know why I insist on using a cacher on this...
# If you know, do tell me! 
feed_content = cacher.retrieve_by_url(FEED_URL, expiration: 100)

feed = Feedzirra::Feed.parse(feed_content)

feed.entries.reverse.each do |entry|
  regex = /^#([0-9]*)\s(.*)$/
  match = regex.match(entry.title)

  raise 'Illformed title. ' unless match

  num = match[1].to_i
  title = match[2]

  # Strip / out of filename.
  path = File.join(OUTPUT_DIR, "%03d %s.mp4" % [num, title.gsub("\/", '_')])

  if File.exists?(path)
    puts "Skipping #{entry.title}"
  else
    url = entry.enclosure_url
    puts "Downloading #{entry.title} ..."
    content = cacher.retrieve_by_url(url, show_progress: true)
    FileUtils.mkdir_p(OUTPUT_DIR)
    File.write(path + '.tmp', content)
    FileUtils.mv(path + '.tmp', path)
  end
end
