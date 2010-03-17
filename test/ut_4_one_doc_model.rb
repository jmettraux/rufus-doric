
#
# testing rufus-doric
#
# Wed Mar 17 15:53:49 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class User < Rufus::Doric::OneDocModel

  doc_id :users
  db :doric

  h_accessor :password
  h_accessor :roles
  h_accessor :locale

  validates :password, :presence => true
end


class UtOneDocModelTest < Test::Unit::TestCase

  def setup

    Rufus::Doric::Couch.db('doric').delete('.')
    Rufus::Doric::Couch.db('doric').put('.')

    users = Rufus::Json.decode(File.read(File.join(
      File.dirname(__FILE__), 'fixtures', 'test', 'doric', 'users.json')))

    Rufus::Doric::Couch.db('doric').put(users)
  end

  #def teardown
  #end

  def test_all

    assert_equal %w[ jami john justin ], User.all.collect { |u| u._id }.sort
  end

  def test_find

    assert_equal(
      { "_id" => "john", "password" => "$2a$10$t8hGTRTPKU1sm2hhDxqFa.moEBrvH2O3ZQazoq4YsC/AKvoTJSIwy" },
      User.find('john').h)
  end

  def test_save

    assert_equal 3, User.all.size

    User.new('_id' => 'james', 'password' => 'nada').save!

    assert_equal(
      %w[ james jami john justin ],
      User.all.collect { |u| u._id }.sort)
  end

  def test_validation

    assert_raise ActiveRecord::RecordInvalid do
      User.new('_id' => 'jeff').save!
    end
  end

  def test_delete

    User.find('john').delete

    assert_equal %w[ jami justin ], User.all.collect { |u| u._id }.sort
  end
end

