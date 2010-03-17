
#
# testing rufus-doric
#
# Wed Mar 17 12:21:18 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Thing < Rufus::Doric::Model
  db 'doric'
  doric_type :things
  _id_field :name
  h_accessor :name
end


class UtModelTest < Test::Unit::TestCase

  def setup
    ::Thing.destroy_all
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
end

