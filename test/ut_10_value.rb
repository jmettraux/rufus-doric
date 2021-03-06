
#
# testing rufus-doric
#
# Thu Mar 18 22:30:00 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Tuples < Rufus::Doric::Value

  doc_id :tuples
  db :doric

  def to_s

    value.sort.join(' ')
  end
end

class Misc < Rufus::Doric::Value

  doc_id :misc
  db :doric

  h_shortcut :product_lines
end


class UtValueTest < Test::Unit::TestCase

  def setup

    @db = Rufus::Doric.db('doric')
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
    tuples.value << 'borneo'
    tuples.save!

    assert_equal 'alpha borneo bravo charly', tuples.to_s
    assert_equal 'alpha borneo bravo charly', Tuples.load.to_s
  end

  def test_save_new

    @db.delete(Tuples.load.h)

    assert_nil @db.get('tuples')

    tuples = Tuples.new(
      '_id' => 'tuples', 'value' => %w[ alpha beta delta gamma ]).save!

    assert_equal 'alpha beta delta gamma', Tuples.load.to_s
  end

  def test_h_shortcut

    Misc.new(
      '_id' => 'misc', 'value' => { 'product_lines' => %w[ a b c ]}).save!

    assert_equal %w[ a b c ], Misc.product_lines
  end
end

