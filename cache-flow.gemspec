Gem::Specification.new do |s|
  s.name        = 'cache-flow'
  s.version     = '0.0.6'
  s.date        = '2014-06-18'
  s.summary     = 'A gem to manage when your cache expires.'
  s.description = 'Define a window of time to have all your cache expire randomly within.'
  s.authors     = ['Dan DeMeyere']
  s.email       = 'dan.demeyere@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/dandemeyere/cache-flow'
  s.license     = 'MIT'
  s.add_dependency('activesupport','>= 3.1.0')
  s.add_dependency('i18n', '>= 0.6.9')
  s.add_dependency('tzinfo', '0.3.38')
  s.add_development_dependency('rspec', '3.2.0')
end
