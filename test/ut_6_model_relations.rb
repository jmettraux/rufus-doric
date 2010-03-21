
#
# testing rufus-doric
#
# Sun Mar 21 12:07:00 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Customer < Rufus::Doric::Model

  db :doric
  doric_type :customers

  _id_field :name

  h_accessor :name
  h_accessor :region_id
end

class Region < Rufus::Doric::Model

  db :doric
  doric_type :regions

  _id_field :name

  h_accessor :name
end

class Order < Rufus::Doric::Model

  db :doric
  doric_type :orders

  _id_field :order_id

  h_accessor :order_id
  h_accessor :customer_id
end


class UtModelTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Customer.new(:name => 'fred', :region_id => 'eu').save!
    Region.new(:name => 'eu').save!
    Order.new(:order_id => 'a', :customer_id => 'fred').save!
    Order.new(:order_id => 'b', :customer_id => 'fred').save!
    Order.new(:order_id => 'c', :customer_id => 'nemo').save!
  end

  #def teardown
  #end

  def test_belongs_to

    o = Order.find('a')
    c = Customer.find('fred')

    assert_equal c, o.customer
  end

  def test_missing_customer

    assert_raise Rufus::Doric::NotFound do
      Order.find('c').customer
    end
  end
end

