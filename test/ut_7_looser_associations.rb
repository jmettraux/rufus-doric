
#
# testing rufus-doric
#
# Tue Mar 23 11:07:23 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Owner < Rufus::Doric::Model

  db :doric
  doric_type :owners

  _id_field :name

  property :name
  property :vehicle_id
end

class Car < Rufus::Doric::Model

  db :doric
  doric_type :cars

  _id_field :plate

  property :plate
end

class Boat < Rufus::Doric::Model

  db :doric
  doric_type :boats

  _id_field :immatriculation

  property :immatriculation
end

class SuperOwner < Rufus::Doric::Model

  db :doric
  doric_type :super_owners

  _id_field :name

  property :name
  property :vehicle_ids
end


class UtLooserAssocationsTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Owner.new(
      :name => 'fred', :vehicle_id => 'GE1212'
    ).save!
    Owner.new(
      :name => 'famke', :vehicle_id => 'GE1313'
    ).save!
    Owner.new(
      :name => 'fellini', :vehicle_id => 'TO45R4'
    ).save!

    Car.new(:plate => 'GE1212').save!
    Boat.new(:immatriculation => 'GE1313').save!

    SuperOwner.new(
      :name => 'aristotle', :vehicle_ids => %w[ GE1212 GE1313 NADA ]).save!

    @fred = Owner.find('fred')
    @famke = Owner.find('famke')
    @fellini = Owner.find('fellini')
    @aristotle = SuperOwner.find('aristotle')
  end

  #def teardown
  #end

  def test_vehicles

    assert_equal Car, @fred.vehicle.class
    assert_equal Boat, @famke.vehicle.class
    assert_nil @fellini.vehicle
  end

  def test_super_owner

    assert_equal [ Car, Boat ], @aristotle.vehicles.collect { |v| v.class }
  end
end

