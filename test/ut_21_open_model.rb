
#
# testing rufus-doric
#
# Wed Jun 30 15:05:56 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Audit < Rufus::Doric::Model

  db :doric
  doric_type :audits

  open

  _id_field { "audit_#{name}" }
  property :name
end

class Participant < Rufus::Doric::Model

  db :doric
  doric_type :audits

  _id_field { "participant_#{name}" }
  property :name
end


class UtOpenModelTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_openness

    a = Audit.new(:name => 'nada')
    a.save!

    assert_equal nil, a.clerk
    assert_equal nil, a.whatever

    a = Audit.all.first
    a.clerk = 'Wilfried'
    a.save!

    assert_equal 'Wilfried', a.clerk
  end

  def test_remove

    a = Audit.new(:name => 'berlusconi')
    a.h['country'] = 'x'

    a.remove(:country)

    assert_equal %w[ doric_type name ], a.h.keys.sort
  end

  def test_remove_on_a_closed_model

    Participant.new(:name => 'Joseph').save!

    pa = Participant.all.first

    assert_raise RuntimeError do
      pa.remove(:nationality)
    end
  end
end

