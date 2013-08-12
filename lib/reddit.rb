require 'sequel'
require 'faraday'
require 'faraday_middleware'
require 'logger'

LOGGER = Logger.new(STDOUT)

DB = Sequel.connect(
  :adapter  => 'postgres',
  :database => 'reddit_stats',
  :username => 'root',
  :host     => 'localhost',
  :encoding => 'UTF-8'
)

unless DB.table_exists?(:posts)
  DB.create_table(:posts) do
    primary_key :id

    String :title
    String :reddit_id, :unique => true
    String :subreddit
    String :author
    String :url
    String :body, :text => true

    String :title_gender
    String :body_gender

    Integer :upvotes, :default => 1
    Integer :downvotes, :default => 0
    Integer :comments, :default => 0

    Time :created_at
    Time :posted_at
  end
end

unless DB.table_exists?(:comments)
  DB.create_table(:comments) do
    primary_key :id

    foreign_key :post_id, :posts,
      :on_delete => :cascade,
      :on_update => :cascade

    String :author
    String :reddit_id
    String :parent_id
    String :comment, :text => true

    Integer :upvotes, :default => 1
    Integer :downvotes, :default => 0

    Time :created_at
    Time :posted_at
  end
end

class Post < Sequel::Model
  one_to_many :comments

  plugin :timestamps, :created => :created_at
end

class Comment < Sequel::Model
  many_to_one :post
  many_to_one :parent, :class => self
  one_to_many :children, :key => :parent_id, :class => self
end

# fuckit, globals.
HTTP = Faraday.new do |conn|
  conn.response(:json)
  conn.response(:follow_redirects)
  conn.adapter(Faraday.default_adapter)
end

SUBREDDIT = ENV['SUBREDDIT'] || 'amsterdam'
