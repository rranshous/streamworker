Gem::Specification.new do |s|
  s.name          = 'streamworker'
  s.version       = '0.0.8'
  s.licenses      = ['BeerWare']
  s.summary       = "Work on events in a stream"
  s.description   = "Subscribe to eventstore stream, work on all events"
  s.authors       = ["Robby Ranshous"]
  s.email         = "rranshous@gmail.com"
  s.files         = ["streamworker.rb"]
  s.homepage      = "https://github.com/rranshous/streamworker"
  s.require_paths = ['.']
  s.add_dependency 'eventstore', '~> 0.1.2'
  s.add_dependency 'redis-namespace', '~> 1.5.1'
end
