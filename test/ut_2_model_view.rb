
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


class UtModelTest < Test::Unit::TestCase

  def setup
    Rufus::Doric::Couch.db('doric').delete('.')
    Rufus::Doric::Couch.db('doric').put('.')
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

    assert_not_nil Nada::Thing.db.get('_design/doric_nada__thing')
  end
end

