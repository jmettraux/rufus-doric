
#
# testing rufus-doric
#
# Wed Mar 17 12:21:18 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Thing < Rufus::Doric::Model

  db :doric

  doric_type :things
  _id_field :name
  h_accessor :name
end

class Item < Rufus::Doric::Model

  db :doric

  doric_type :items

  _id_field :name
  h_accessor :name
  h_accessor :supplier

  validates :supplier, :presence => true
end


class UtModelTest < Test::Unit::TestCase

  def setup
    Rufus::Doric::Couch.db('doric').delete('.')
    Rufus::Doric::Couch.db('doric').put('.')
  end
  #def teardown
  #end

  def test_save

    Thing.new(
      'name' => 'toto'
    ).save!

    assert_equal 1, Thing.all.size
    assert_equal 'toto', Thing.all.first._id
  end

  def test_failing_save

    Thing.new(
      'name' => 'toto'
    ).save!

    assert_raise Rufus::Doric::SaveFailed do
      Thing.new(
        'name' => 'toto'
      ).save!
    end
  end

  def test_copy

    Thing.new(
      'name' => 'toto'
    ).save!

    t = Thing.all.first

    assert_not_nil t._id

    c = t.copy

    assert_nil c._id
    assert_nil c._rev
    assert_equal Thing, c.class
  end

  def test_validation

    assert_raise ActiveRecord::RecordInvalid do
      Item.new('name' => 'pasokon').save!
    end
  end

  def test_delete

    Thing.new('name' => 'song_celine').save!

    assert_equal 1, Thing.all.size

    t = Thing.all.first

    t.delete

    assert_equal 0, Thing.all.size
    assert_equal true, t.destroyed?
  end

  def test_not_found

    assert_raise Rufus::Doric::NotFound do
      Thing.find('nada')
    end
  end
end

