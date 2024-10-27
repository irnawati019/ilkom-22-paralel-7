workers ENV.fetch('WEB_CONCURRENCY') { 2 }
threads_count = ENV.fetch('THREAD_POOL_SIZE') { 5 }
threads threads_count, threads_count

port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }

preload_app!