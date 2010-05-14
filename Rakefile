

require 'lib/rufus/doric/version.rb'

require 'rubygems'
require 'rake'


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html')
task :default => [ :clean ]


#
# GEM

require 'jeweler'

Jeweler::Tasks.new do |gem|

  gem.version = Rufus::Doric::VERSION
  gem.name = 'rufus-doric'
  gem.summary = 'something at the intersection of Rails3, CouchDB and rufus-jig'

  gem.description = %{
something at the intersection of Rails3, CouchDB and rufus-jig
  }
  gem.email = 'jmettraux@gmail.com'
  gem.homepage = 'http://github.com/jmettraux/rufus-doric/'
  gem.authors = [ 'John Mettraux' ]
  gem.rubyforge_project = 'rufus'

  gem.test_file = 'test/test.rb'

  gem.add_dependency 'activerecord', '~> 3.0.0.beta3'
  gem.add_dependency 'rufus-jig', '>= 0.1.19'
  gem.add_dependency 'mime-types', '>= 1.16'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'jeweler'

  # gemspec spec : http://www.rubygems.org/read/chapter/20
end
Jeweler::GemcutterTasks.new


#
# DOC

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |doc|
    doc.options = [
      '-o', 'html/rufus-doric', '--title',
      "rufus-doric #{Rufus::Doric::VERSION}"
    ]
  end
rescue LoadError
  task :yard do
    abort "YARD is not available : sudo gem install yard"
  end
end


#
# TO THE WEB

task :upload_website => [ :clean, :yard ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-doric #{account}:#{webdir}/"
end

