
#
# testing rufus-doric
#
# Mon Apr 12 14:48:28 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Place < Rufus::Doric::OneDocModel

  doc_id :places
  db :doric

  h_accessor :name
  h_accessor :zip
  h_accessor :country, :default => 'UK'
  h_accessor :neighbours, :default => []
end


class UtOneDocModelDefaultTest < Test::Unit::TestCase

  #def setup
  #  Rufus::Doric.db('doric').delete('.')
  #  Rufus::Doric.db('doric').put('.')
  #end
  #def teardown
  #end

  def test_defaults

    assert_equal(
      { 'country' => 'UK', 'neighbours' => [] },
      Place.defaults)
  end

  def test_default

    london = Place.new(:name => 'London')
    berlin = Place.new(:name => 'Berlin', :country => 'Germany')

    assert_equal 'UK', london.country
    assert_equal 'Germany', berlin.country
  end

  def test_default_is_not_shared_among_all_instances

    tokyo = Place.new(:name => 'Tokyo')
    hiroshima = Place.new(:name => 'Hiroshima')

    tokyo.neighbours << 'Yokohama'

    assert_equal [], hiroshima.neighbours
  end
end

