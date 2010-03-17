
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
    couch = Rufus::Jig::Couch.new(Rufus::Doric::Couch.url)
    couch.delete('doric_test')
    couch.delete('doric_nada')
    couch.delete('doric')
    couch.close
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

    img = Rufus::Doric::Couch.db('doric', :env => 'nada').get('users/john.jpg')

    assert_not_nil img
  end

  def test_absolute_option

    Rufus::Doric::Fixtures.load(
      Rufus::Doric::Couch.url, 'test/fixtures/test',
      :db => 'doric',
      :purge => true,
      :verbose => false)

    img = Rufus::Doric::Couch.db('doric', :absolute => true).get('users/john.jpg')

    assert_not_nil img
  end
end

