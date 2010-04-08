
#
# testing rufus-doric
#
# Thu Apr  8 18:24:26 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')


class Hobo < Rufus::Doric::OneDocModel

  doc_id :hobos
  db :doric

  h_accessor :name
end


class UtOneDocModelLintTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = Hobo.new(:name => 'john')
  end
  #def teardown
  #end
end

