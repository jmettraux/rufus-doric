
#
# testing rufus-doric
#
# Fri Apr 16 13:46:53 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Squad < Rufus::Doric::Model

  db :doric
  doric_type :squads

  h_accessor :type
  h_accessor :ranking

  view_by :ranking
  view_by [ :type, :ranking ]
end


class UtModelViewByAndTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Squad.new(
      'type' => 'rifle',
      'ranking' => 'first'
    ).save!
    Squad.new(
      'type' => 'rifle',
      'ranking' => 'first'
    ).save!
    Squad.new(
      'type' => 'artillery',
      'ranking' => 'second'
    ).save!
    Squad.new(
      'type' => 'artillery',
      'ranking' => 'first'
    ).save!
  end

  #def teardown
  #end

  def test_view_by_and

    assert_equal 2, Squad.by_type_and_ranking([ 'rifle', 'first' ]).size
    assert_equal 3, Squad.by_ranking('first').size
  end

  def test_view_raw

    br = Squad.by_ranking('first', :raw => true)
    btar = Squad.by_type_and_ranking([ 'rifle', 'first' ], :raw => true)

    assert_equal 3, br.size
    assert_equal Hash, br.first.class
    assert_equal %w[ doc id key value ], br.first.keys.sort

    assert_equal 2, btar.size
  end
end

