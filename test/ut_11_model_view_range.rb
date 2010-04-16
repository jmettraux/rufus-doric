
#
# testing rufus-doric
#
# Mon Apr 12 10:38:53 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Schedule < Rufus::Doric::Model

  db :doric
  doric_type :schedules

  _id_field :name
  h_accessor :name
  h_accessor :day #yyyymmdd

  view_by :day
end


class UtModelViewRangeTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'

    Schedule.new('name' => 'wrestling', 'day' => '20101224').save!
    Schedule.new('name' => 'shopping', 'day' => '20101224').save!
    Schedule.new('name' => 'cooking', 'day' => '20101225').save!
    Schedule.new('name' => 'climbing', 'day' => '20101226').save!
    Schedule.new('name' => 'drinking', 'day' => '20101227').save!
  end

  #def teardown
  #end

  def test_view_by_range

    assert_equal 'shopping', Schedule.by_day('20101224').first.name

    assert_equal(
      %w[ climbing drinking ],
      Schedule.by_day(:start => '20101226').collect { |s| s.name })
    assert_equal(
      %w[ climbing drinking ],
      Schedule.by_day(:start => '20101226', :end => nil).collect { |s| s.name })

    assert_equal(
      %w[ shopping wrestling cooking ],
      Schedule.by_day(:end => '20101225').collect { |s| s.name })
    assert_equal(
      %w[ shopping wrestling cooking ],
      Schedule.by_day(:start => nil, :end => '20101225').collect { |s| s.name })

    assert_equal(
      %w[ drinking climbing cooking ],
      Schedule.by_day(:end => '20101225', :descending => true).collect { |s| s.name })
  end

  def test_view_limit

    assert_equal(
      %w[ shopping ],
      Schedule.by_day('20101224', :limit => 1).collect { |s| s.name })

    assert_equal(
      %w[ climbing ],
      Schedule.by_day(:start => '20101226', :limit => 1).collect { |s| s.name })
    assert_equal(
      %w[ drinking ],
      Schedule.by_day(:start => '20101226', :skip => 1).collect { |s| s.name })
  end

  def test_all_opts

    assert_equal 4, Schedule.all(:skip => 1).size
    assert_equal 2, Schedule.all(:skip => 2, :limit => 2).size
  end
end

