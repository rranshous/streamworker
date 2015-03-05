require_relative 'worker'
require 'eventstore'
require 'redis-namespace'

module StreamWorker
  def run!
    puts "Running #{@handler_name || @stream}"
    STDOUT.flush
    @worker.run! eventstore, namespaced_redis(@handler_name)
  end
  def handle stream, &blk
    if stream.is_a?(Hash)
      stream, event_type = stream.first
    else
      stream = stream
      event_type = nil
    end
    @worker = StreamWorker::Worker.new @handler_name, stream, event_type, blk
  end
  def eventstore
    return @eventstore if @eventstore
    @eventstore ||= EventStore::Client.new eventstore_conn_string
  end
  def eventstore_conn_string
    # most strait forward way to set
    url = ENV['EVENTSTORE_URL']
    # check for docker link vars
    if ENV['EVENTSTORE_PORT']
      host_port = ENV['EVENTSTORE_PORT'].split('//').last
      url = "http://#{host_port}"
    end
    # fall back to local
    url ||= 'http://0.0.0.0:2113'
    url
  end
  def name handler_name
    @handler_name = handler_name
  end
  def emit stream, event_type, data
    eventstore.write_event stream, event_type, data
  end
  def redis_client
    @handler_name ? namespaced_redis(@handler_name) : nil
  end
  def namespaced_redis namespace
    Redis::Namespace.new(namespace, :redis => redis_connection)
  end
  def redis_connection
    # will use REDIS_URL as connection string
    @redis_connection ||= Redis.new
  end
  def log msg
    @worker.log msg
  end
end
include StreamWorker

class State
end

at_exit do
  if $!.nil? && @handler
    run!
  end
end
