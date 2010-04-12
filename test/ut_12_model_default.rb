
#
# testing rufus-doric
#
# Mon Apr 12 14:32:35 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Can < Rufus::Doric::Model

  db :doric
  doric_type :cans

  _id_field :serial
  h_accessor :serial
  h_accessor :content, :default => 'tuna'
  h_accessor :colour
end


class UtModelDefaultTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_default

    Can.new(:serial => 'abcd', :content => 'anchovy').save!
    Can.new(:serial => 'efgh').save!

    assert_equal({ 'content' => 'tuna' }, Can.defaults)

    assert_equal 'anchovy', Can.find('abcd').content
    assert_equal 'tuna', Can.find('efgh').content
    assert_equal nil, Can.find('abcd').colour
  end
end

