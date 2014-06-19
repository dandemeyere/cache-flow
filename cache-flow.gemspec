Gem::Specification.new do |s|
  s.name        = 'cache-flow'
  s.version     = '0.0.2'
  s.date        = '2014-06-18'
  s.summary     = "A gem to manage when your cache expires."
  s.description = "Define a window of time to have all your cache expire randomly within."
  s.authors     = ["Dan DeMeyere"]
  s.email       = 'dan.demeyere@gmail.com'
  s.files       = ["lib/cache-flow.rb"]
  s.homepage    = 'https://github.com/dandemeyere/cache-flow'
  s.license     = 'MIT'
  s.add_dependency("business_time", "0.6.1")
  s.add_development_dependency("rspec", "3.0.0")
end
