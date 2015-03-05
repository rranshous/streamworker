module StreamWorker
  class Worker
    attr_accessor :name, :stream, :event_type

    def initialize name, stream, event_type, handler
      @name = name
      @stream = stream
      @event_type = event_type
      @handler = handler
      @state = Hash.new
    end

    def run! eventstore, redis
      EventStore::Util.poll(eventstore, @stream).each do |event|
        next if @event_type && event[:type] != @event_type
        puts "handling: #{event[:id]}"
        @current_event = event
        @handler.call @state, event, redis
        STDOUT.flush
      end
    end

    def log msg
      print "#{@name}|" if @name
      print "[#{@current_event[:id]}]" if @current_event
      puts " #{msg}"
    end
  end
end
