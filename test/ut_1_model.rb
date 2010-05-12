
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

class Concept < Rufus::Doric::Model

  db :doric
  doric_type :concepts
  _id_field :name
  property :name
end


class UtModelTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_types

    assert_equal Hash, Rufus::Doric.types.class
    assert_equal Concept, Rufus::Doric.types['concepts']
  end

  def test_defaults

    assert_equal({}, Concept.defaults)
  end

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

  def test_missing_id_when_saving

    assert_raise ActiveRecord::RecordInvalid do
      Thing.new(
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
      Thing.find('gozaimasen')
    end
  end

  def test_destroy_all

    Thing.new('name' => 'dokodemo').save!

    assert_equal 1, Thing.all.size

    Thing.destroy_all

    assert_equal 0, Thing.all.size
  end

  def test_putting_in_missing_db

    Rufus::Doric.db('doric').delete('.')

    assert_raise Rufus::Doric::SaveFailed do
      Thing.new('name' => 'doraemon').save!
    end
  end

  def test_equality

    Thing.new('name' => 'onaji').save!
    Thing.new('name' => 'chigau').save!

    a = Thing.find('onaji')
    b = Thing.find('onaji')
    c = Thing.find('chigau')

    assert_equal a, b
    assert_equal a.hash, b.hash

    assert_not_equal a, c
    assert_not_equal a.hash, c.hash
  end

  def test_property

    Concept.new('name' => 'art').save!

    c = Concept.find('art')

    assert_equal 'art', c.name
  end

  def test_attach

    txt = File.read(__FILE__)

    t = Thing.new('name' => 'piece_of_code')
    t.save!

    assert_equal [], t.attachments

    t.attach('code.txt', txt)

    t = Thing.find('piece_of_code')

    assert_equal [ 'code.txt' ], t.attachments
    assert_equal txt, t.db.get('piece_of_code/code.txt')
  end
end

