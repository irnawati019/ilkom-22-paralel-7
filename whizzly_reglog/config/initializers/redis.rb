require 'redis'

REDIS = Redis.new(
  host: ENV['REDIS_HOST'] || 'localhost',
  port: ENV['REDIS_PORT'] || 6379,
  db: ENV['REDIS_DB'] || 0
)