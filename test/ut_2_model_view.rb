
#
# testing rufus-doric
#
# Wed Mar 17 14:27:30 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


module Nada
  class Thing < Rufus::Doric::Model

    db :doric
    doric_type :things

    _id_field :name
    h_accessor :name
    h_accessor :colour

    view_by :colour
  end
end


class UtModelViewTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_view_by_colour

    Nada::Thing.new(
      'name' => 'toto',
      'colour' => 'blue'
    ).save!
    Nada::Thing.new(
      'name' => 'alfred',
      'colour' => 'red'
    ).save!
    Nada::Thing.new(
      'name' => 'ivan',
      'colour' => 'red'
    ).save!

    assert_equal 3, Nada::Thing.all.size
    assert_equal 1, Nada::Thing.by_colour('blue').size
    assert_equal 2, Nada::Thing.by_colour('red').size

    assert_equal Nada::Thing, Nada::Thing.all.first.class
    assert_equal Nada::Thing, Nada::Thing.by_colour('blue').first.class

    assert_not_nil Nada::Thing.db.get('_design/doric_nada__thing')
  end

  def test_no_infinite_loop_when_missing_db

    Rufus::Doric.db('doric').delete('.')

    assert_raise RuntimeError do
      Nada::Thing.by_colour('blue').size
    end
  end

  def test_nuke_design_documents

    assert_nil Nada::Thing.db.get('_design/doric_nada__thing')

    assert_equal [], Nada::Thing.by_colour('blue')

    Nada::Thing.db.nuke_design_documents

    assert_nil Nada::Thing.db.get('_design/doric_nada__thing')
  end
end

