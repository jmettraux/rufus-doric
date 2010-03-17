
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
    Rufus::Jig::Couch.new('http://127.0.0.1:5984').delete('doric_test')
    Rufus::Jig::Couch.new('http://127.0.0.1:5984').delete('doric_nada')
  end

  def test_load

    Rufus::Doric::Fixtures.load(
      'http://127.0.0.1:5984', 'test/fixtures/test',
      :purge => true,
      :verbose => false)

    img = Rufus::Jig::Couch.new(
      'http://127.0.0.1:5984/doric_test').get('users/john.jpg')

    assert_not_nil img
  end

  def test_env_option

    Rufus::Doric::Fixtures.load(
      'http://127.0.0.1:5984', 'test/fixtures/test',
      :env => 'nada',
      :purge => true,
      :verbose => false)

    img = Rufus::Jig::Couch.new(
      'http://127.0.0.1:5984/doric_nada').get('users/john.jpg')

    assert_not_nil img
  end
end

