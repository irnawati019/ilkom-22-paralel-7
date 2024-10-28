FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile dan install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy aplikasi
COPY . .

# Environment variables
ENV RACK_ENV=production
ENV THREAD_POOL_SIZE=10
ENV THREAD_POOL_QUEUE=100

# Expose port
EXPOSE 3000

# Start the application dengan Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
