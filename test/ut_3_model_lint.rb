
#
# testing rufus-doric
#
# Wed Mar 17 15:14:33 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')


class Item < Rufus::Doric::Model
  doric_type :items
  _id_field :name
  h_accessor :name
end


class UtLintModelTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = Item.new
  end
  #def teardown
  #end
end

