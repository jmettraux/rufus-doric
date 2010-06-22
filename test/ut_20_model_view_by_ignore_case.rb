
#
# testing rufus-doric
#
# Tue Jun 22 15:07:22 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Handkerchief < Rufus::Doric::Model

  db :doric
  doric_type :handkerchief

  _id_field { [ brand, colour, owner ].join('_').downcase }
  h_accessor :brand
  h_accessor :colour
  h_accessor :owner

  view_by :colour
  view_by :owner, :ignore_case => true
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

  def test_view_by_owner

    load_data

    assert_equal 1, Handkerchief.by_owner('pepe').size
    assert_equal 2, Handkerchief.by_owner('jefe').size

    assert_equal 0, Handkerchief.by_owner('Pepe').size
    assert_equal 0, Handkerchief.by_owner('Jefe').size
  end

  def test_view_by_colour

    load_data

    assert_equal 1, Handkerchief.by_colour('brown').size
    assert_equal 1, Handkerchief.by_colour('Brown').size
    assert_equal 1, Handkerchief.by_colour('browN').size
  end

  protected

  def load_data

    Handkerchief.new(
      :brand => 'valentino', :colour => 'browN', :owner => 'Pepe'
    ).save!
    Handkerchief.new(
      :brand => 'lv', :colour => 'brown', :owner => 'Jefe'
    ).save!
    Handkerchief.new(
      :brand => 'chanel', :colour => 'Brown', :owner => 'jefe'
    ).save!
  end
end

