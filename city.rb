#football_news_rss_url = "http://feeds.bbci.co.uk/sport/0/football/rss.xml"
require 'feedjira'
require 'sqlite3'
require 'postmark'

POSTMARK_API_KEY = File.read(".postmark_api_key").strip
EMAIL_ADDRESS = ARGV[0]

class DBConn
	def initialize(database_filename)
		@db = SQLite3::Database.new(database_filename)
		@db.execute('create table if not exists city_news (title varchar, date integer);')
		last_week = Time.now.to_i - 604800
		@db.execute('delete from city_news where date < ?', last_week)
	end

	def add_story(title, date)
		rows = @db.execute('select * from city_news where title = ?', title)

		if rows.length == 0
			@db.execute( "insert into city_news (title, date) values ( ?, ? )", title, date.to_i)
			return true
		end

		return false
	end
end

def format_stories(stories)
	stories.map{|story| "#{story.title}\n#{story.summary}\n#{story.url}" }.join("\n\n")
end

##########################################################################################

db = DBConn.new("city_news.sqlite")

feed = Feedjira::Feed.fetch_and_parse("http://feeds.bbci.co.uk/sport/0/football/rss.xml")
news_stories = []
feed.entries.each do |entry|
	if entry.title[0..4] != "VIDEO"
		if entry.published > (Time.now - 604800)
			if entry.title =~ /man(?:chester)?\s+City/i
				if db.add_story(entry.title, entry.published)
					news_stories << entry
				end
			end
		end
	end
end

if !news_stories.empty?
	formatted_stories = format_stories(news_stories)
	puts formatted_stories
	
	your_api_key = POSTMARK_API_KEY
	client = Postmark::ApiClient.new(your_api_key)
	
	client.deliver(
		from: EMAIL_ADDRESS,
		to: EMAIL_ADDRESS,
		subject: 'City news',
		text_body: formatted_stories
	)
end
