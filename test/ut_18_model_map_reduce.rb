
#
# testing rufus-doric
#
# Fri May 21 23:41:59 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Auth < Rufus::Doric::Model

  db :doric
  doric_type :auths

  h_accessor :role
  h_accessor :user

  view_by 'roles', %{
    emit(null, doc.role);
  }, %{
    // unique ...
    var a = [];
    for (var i = 0; i < values.length; i++) {
      var v = values[i];
      if (a.indexOf(v) < 0) a.push(v);
    }
    return a;
  }
end


class UtModelMapReduceTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_mr

    Auth.new('role' => 'president', 'user' => 'Amedeo').save!
    Auth.new('role' => 'prime minister', 'user' => 'Claudio').save!
    Auth.new('role' => 'minister of war', 'user' => 'Sergio').save!
    Auth.new('role' => 'minister of war', 'user' => 'John').save!

    assert_equal(
      [ 'president', 'prime minister', 'minister of war' ],
      Auth.roles(nil))
  end
end

