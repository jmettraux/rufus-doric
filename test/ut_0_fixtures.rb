
#
# testing rufus-doric
#
# Wed Mar 17 10:34:05 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric/fixtures'


class UtFixturesTest < Test::Unit::TestCase

  #def setup
  #end
  def teardown
    Rufus::Doric::Couch.db('doric').delete('.')
    Rufus::Doric::Couch.db('doric', 'nada').delete('.')
  end

  def test_load

    Rufus::Doric::Fixtures.load(
      Rufus::Doric::Couch.url, 'test/fixtures/test',
      :purge => true,
      :verbose => false)

    img = Rufus::Doric::Couch.db('doric').get('users/john.jpg')

    assert_not_nil img
  end

  def test_env_option

    Rufus::Doric::Fixtures.load(
      Rufus::Doric::Couch.url, 'test/fixtures/test',
      :env => 'nada',
      :purge => true,
      :verbose => false)

    img = Rufus::Doric::Couch.db('doric', 'nada').get('users/john.jpg')

    assert_not_nil img
  end
end

