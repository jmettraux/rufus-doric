
#
# testing rufus-doric
#
# Fri Apr 16 15:19:46 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Team < Rufus::Doric::Model

  db :doric
  doric_type :teams

  h_accessor :type
  h_accessor :security_level
  h_accessor :headcount

  view_by 'tysec', %{
    emit(doc.type + '__' + doc.security_level, null);
  }
  view 'tysec2', %{
    emit([ doc.type, doc.security_level ], null);
  }
end


class UtModelCustomViewTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_views

    Team.new(
      'type' => 'rifle',
      'security_level' => 'a'
    ).save!
    Team.new(
      'type' => 'rifle',
      'security_level' => 'a'
    ).save!
    Team.new(
      'type' => 'rifle',
      'security_level' => 'b'
    ).save!
    Team.new(
      'type' => 'artillery',
      'security_level' => 'a'
    ).save!
    Team.new(
      'type' => 'artillery',
      'security_level' => 'c'
    ).save!

    assert_equal 2, Team.tysec('rifle__a').size
    assert_equal 1, Team.tysec('rifle__b').size

    assert_equal 2, Team.tysec2(%w[ rifle a ]).size
  end
end

