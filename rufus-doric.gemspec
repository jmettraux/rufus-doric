
Gem::Specification.new do |s|

  s.name = 'rufus-doric'

  s.version = File.read(
    File.expand_path('../lib/rufus/doric/version.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://github.com/jmettraux/rufus-doric'
  s.rubyforge_project = 'rufus'
  s.license = 'MIT'
  s.summary = 'something at the intersection of Rails3, CouchDB and rufus-jig'

  s.description = %{
something at the intersection of Rails3, CouchDB and rufus-jig
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', 'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'activerecord', '~> 3.0.0'
  s.add_runtime_dependency 'mime-types', '~> 1.16'
  s.add_runtime_dependency 'rufus-jig', '>= 0.1.23'

  s.add_development_dependency 'rake'

  s.require_path = 'lib'
end

