
#
# testing rufus-doric
#
# Thu Apr  1 10:32:57 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Product < Rufus::Doric::Model

  db :doric
  doric_type :products

  _id_field :serial_number

  property :serial_number
  property :name
  property :brand
  property :category
  property :comment

  text_index :serial_number, :name, :brand
end

class Whatever < Rufus::Doric::Model

  db :doric
  doric_type :whatevers

  _id_field :name

  property :name
end


class UtAnyTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Product.new(
      :serial_number => 'h2o',
      :name => 'water',
      :brand => 'earth',
      :category => 'drink',
      :comment => nil
    ).save!
    Product.new(
      :serial_number => '951',
      :name => 'seamaster professional',
      :brand => 'omega',
      :category => 'watches',
      :comment => 'want as well'
    ).save!
    Product.new(
      :serial_number => 'lv52',
      :name => 'leather bag, for men',
      :brand => 'lv',
      :category => 'bags',
      :comment => nil
    ).save!
    Product.new(
      :serial_number => '0kcal',
      :name => 'zero',
      :brand => 'coca-cola',
      :category => 'drink',
      :comment => nil
    ).save!
    Product.new(
      :serial_number => 'tell2',
      :name => 'tell bag',
      :brand => 'victorinox',
      :category => 'bags',
      :comment => nil
    ).save!

    Whatever.new(
      :name => 'whatever'
    ).save!
  end

  #def teardown
  #end

  def test_no_texts

    assert_nil Whatever.texts
  end

  def test_texts

    index = Product.texts

    #p index

    assert_equal %w[ lv52 tell2 ], index['bag'].sort
    assert_equal nil, index['products']
  end

  def test_texts_key

    assert_equal [ '951' ], Product.texts('omega')
  end
end

