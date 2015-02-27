require 'eventstore'
require 'redis-namespace'

module StreamWorker
  def run!
    state = Hash.new
    EventStore::Util.poll(eventstore, @stream).each do |event|
      next if @event_type && event[:type] != @event_type
      @current_event = event
      @handler.call state, event, redis_client
      STDOUT.flush
    end
  end
  def handle stream, &blk
    if stream.is_a?(Hash)
      @stream = stream.keys.first
      @event_type = stream.values.first
    else
      @stream = stream
      @event_type = nil
    end
    @handler = blk
  end
  def eventstore
    return @eventstore if @eventstore
    default_url = 'http://0.0.0.0:2113'
    @eventstore ||= EventStore::Client.new ENV['EVENTSTORE_URL'] || default_url
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
    print "#{@handler_name}|" if @handler_name
    print "#{@stream}:" if @stream && !@handler_name
    print ":#{@event_type}" if @event_type && !@handler_name
    print "[#{@current_event[:id]}]" if @current_event
    puts " #{msg}"
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
