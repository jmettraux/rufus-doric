# encoding: UTF-8

#
# testing rufus-doric
#
# Mon Jun 21 11:09:39 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class UtNeutralizeTest < Test::Unit::TestCase

  def test_quotes

    assert_equal "_hogehoge__foo", n('"hogehoge" foo')
    assert_equal "X'ian", n("X'ian")
  end

  def test_utf8

    assert_equal "横浜", n("横浜")
  end

  def test_common_pitfalls

    assert_equal 'project__3', n('project #3')
    assert_equal 'project__3_a_b_c', n('project #3?a&b=c')
  end

  protected

  def n(s)

    Rufus::Doric.neutralize_id(s)
  end
end

