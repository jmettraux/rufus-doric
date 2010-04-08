
lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(lib) unless $:.include?(lib)

require 'test/unit'

require 'rubygems'
require 'yajl'
require 'patron'

require 'rufus/jig'

ENV['RAILS_ENV'] = 'test'

require 'active_support'
require 'active_record'
require 'active_record/validations'

require 'rufus/doric'

