
#
# testing rufus-doric
#
# Thu Mar 18 22:30:00 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Tuples < Rufus::Doric::List

  doc_id :tuples
  db :doric

  def to_s

    list.sort.join(' ')
  end
end


class UtListModelTest < Test::Unit::TestCase

  def setup

    @db = Rufus::Doric::Couch.db('doric')
    @db.delete('.')
    @db.put('.')

    tuples = Rufus::Json.decode(File.read(File.join(
      File.dirname(__FILE__), 'fixtures', 'test', 'doric', 'tuples.json')))

    @db.put(tuples)
  end

  #def teardown
  #end

  def test_load

    assert_equal 'alpha bravo charly', Tuples.load.to_s
  end

  def test_save

    tuples = Tuples.load
    tuples.list << 'borneo'
    tuples.save!

    assert_equal 'alpha borneo bravo charly', tuples.to_s
    assert_equal 'alpha borneo bravo charly', Tuples.load.to_s
  end

  def test_save_new

    @db.delete(Tuples.load.h)

    assert_nil @db.get('tuples')

    tuples = Tuples.new(
      '_id' => 'tuples', 'list' => %w[ alpha beta delta gamma ]).save!

    assert_equal 'alpha beta delta gamma', Tuples.load.to_s
  end
end

