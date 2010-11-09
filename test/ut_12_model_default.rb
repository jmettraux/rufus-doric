
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
  property :sold, :default => false
  property :customers, :default => []
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

    assert_equal(
      { 'content' => 'tuna', 'sold' => false, 'customers' => [] },
      Can.defaults)

    assert_equal 'anchovy', Can.find('abcd').content
    assert_equal 'tuna', Can.find('efgh').content
    assert_equal nil, Can.find('abcd').colour
    assert_equal false, Can.find('abcd').sold
  end

  def test_default_is_not_shared_among_all_instances

    anchovy = Can.new(:serial => 'anchovy', :content => 'anchovy')
    tuna = Can.new(:serial => 'tuna', :content => 'tuna')

    anchovy.customers << 'alice'
    anchovy.customers << 'bob'

    anchovy.save!
    tuna.save!

    assert_equal %w[ alice bob ], Can.find('anchovy').customers
    assert_equal [], Can.find('tuna').customers
  end
end

