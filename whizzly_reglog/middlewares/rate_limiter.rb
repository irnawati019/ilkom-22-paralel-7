require 'redis'

class RateLimiter
  def initialize(app)
    @app = app
    @redis = Redis.new(url: ENV['REDIS_URL'])
    @max_requests = ENV.fetch('MAX_REQUESTS_PER_MINUTE') { 60 }
  end

  def call(env)
    client_ip = env['REMOTE_ADDR']
    key = "rate_limit:#{client_ip}"
    
    count = @redis.get(key).to_i
    
    if count >= @max_requests
      [429, { 'Content-Type' => 'application/json' }, [{ 
        status: 'error',
        pesan: 'Too many requests. Please try again later.'
      }.to_json]]
    else
      @redis.multi do
        @redis.incr(key)
        @redis.expire(key, 60) # Reset after 1 minute
      end
      
      @app.call(env)
    end
  end
end
