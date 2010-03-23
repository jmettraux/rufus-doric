
#
# testing rufus-doric
#
# Tue Mar 23 13:23:31 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Person < Rufus::Doric::Model

  db :doric
  doric_type :persons

  _id_field :name

  property :name
end

class Book < Rufus::Doric::Model

  db :doric
  doric_type :books

  _id_field :description

  property :description
  property :person_id
end

class Computer < Rufus::Doric::Model

  db :doric
  doric_type :computers

  _id_field :description

  property :description
  property :person_id
end


class UtBelongingsTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Person.new(
      :name => 'friedrisch', :vehicle_id => 'GE1212'
    ).save!

    Book.new(
      :description => 'romance of the three kingdoms',
      :person_id => 'friedrisch'
    ).save!
    Computer.new(
      :description => 'black macbook',
      :person_id => 'friedrisch'
    ).save!
    Computer.new(
      :description => 'old thinkpad',
      :person_id => 'vlad'
    ).save!

    @friedrisch = Person.find('friedrisch')
  end

  #def teardown
  #end

  def test_belongings

    assert_equal(
      %w[ Book Computer ],
      @friedrisch.belongings.map { |b| b.class.name }.sort)

    assert_equal(
      %w[ Book Computer ],
      @friedrisch.belongings.map { |b| b.class.name }.sort)
        # second run shouldn't insert new design_doc
  end
end

