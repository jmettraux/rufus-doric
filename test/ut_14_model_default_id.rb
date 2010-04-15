
#
# testing rufus-doric
#
# Thu Apr 15 15:31:51 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Unknown < Rufus::Doric::Model

  db :doric
  doric_type :unknowns

  #_id_field :serial

  h_accessor :name
end


class UtModelDefaultTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_default_id

    Unknown.new(:name => 'nemo').save!

    assert_equal 1, Unknown.all.size
  end
end

