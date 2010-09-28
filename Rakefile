

require 'lib/rufus/doric/version.rb'

require 'rubygems'
require 'rake'


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html', 'rdoc')
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

  gem.add_dependency 'activerecord', '~> 3.0.0'
  gem.add_dependency 'rufus-jig', '>= 0.1.22'
  gem.add_dependency 'mime-types', '>= 1.16'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'jeweler'

  # gemspec spec : http://www.rubygems.org/read/chapter/20
end
Jeweler::GemcutterTasks.new


#
# DOC

#
# make sure to have rdoc 2.5.x to run that
#
require 'rake/rdoctask'
Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.rdoc_dir = 'rdoc/rufus-doric'
  rd.rdoc_files.include('README.rdoc', 'CHANGELOG.txt', 'lib/**/*.rb')
  rd.title = "rufus-doric #{Rufus::Doric::VERSION}"
end


#
# TO THE WEB

task :upload_rdoc => [ :clean, :rdoc ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh rdoc/rufus-doric #{account}:#{webdir}/"
end

