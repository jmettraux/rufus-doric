
#
# testing rufus-doric
#
# Mon Jun 21 11:09:39 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class UtNeutralizeTest < Test::Unit::TestCase

  def test_neutralize_id

    assert_equal "_hogehoge__foo", n('"hogehoge" foo')
    assert_equal "X'ian", n("X'ian")
  end

  protected

  def n (s)

    Rufus::Doric.neutralize_id(s)
  end
end

