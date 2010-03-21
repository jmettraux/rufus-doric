
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
  h_accessor :interest_ids
end

class Interest < Rufus::Doric::Model

  db :doric
  doric_type :interests

  _id_field :name

  h_accessor :name
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

  view_by :customer_id
end


class UtModelTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Customer.new(
      :name => 'fred', :region_id => 'eu'
    ).save!
    Customer.new(
      :name => 'famke', :region_id => 'eu', :interest_ids => %w[ music dance ]
    ).save!

    Region.new(:name => 'eu').save!

    Order.new(:order_id => 'a', :customer_id => 'fred').save!
    Order.new(:order_id => 'b', :customer_id => 'fred').save!
    Order.new(:order_id => 'c', :customer_id => 'nemo').save!

    Interest.new(:name => 'litterature').save!
    Interest.new(:name => 'music').save!
    Interest.new(:name => 'dance').save!
  end

  #def teardown
  #end

  def test_customer

    o = Order.find('a')
    c = Customer.find('fred')

    assert_equal c, o.customer
  end

  def test_missing_customer

    assert_raise Rufus::Doric::NotFound do
      Order.find('c').customer
    end
  end

  def test_orders

    c = Customer.find('fred')

    os = c.orders

    assert_equal 2, os.size
    assert_equal [ Order ], os.collect { |o| o.class }.sort.uniq
  end

  def test_interests

    fred = Customer.find('fred')
    famke = Customer.find('famke')

    assert_equal [], fred.interests
    assert_equal %w[ dance music ], famke.interests.collect { |i| i.name }.sort
  end
end

