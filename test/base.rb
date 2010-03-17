
lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(lib) unless $:.include?(lib)

require 'test/unit'

require 'rubygems'
require 'yajl'
require 'patron'

require 'rufus/jig'

