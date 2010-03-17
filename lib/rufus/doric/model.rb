#--
# Copyright (c) 2010, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Rufus
module Doric

  #
  # Classes extending that class have 1 Couch document per instance
  #
  class Model

    #extend ActiveModel::Naming
    include ActiveModel::Validations

    #
    # class 'helpers'

    def self.doric_type (rt=nil)

      @doric_type = rt.to_s if rt
      @doric_type
    end

    def self._id_field (field_name=nil, &block)

      @_id_field = field_name.to_s if field_name
      @_id_field = block if block

      @_id_field
    end

    def self.db (dbname=nil)

      @db = dbname.to_s if dbname
      @db
    end

    include WithH

    #
    # constructor and instance methods

    attr_reader :h

    def initialize (doc={})

      @h = doc.inject({}) { |h, (k, v)| h[k.to_s] = v; h }
      @h['doric_type'] = self.class.doric_type
    end

    def _id
      @h['_id']
    end

    def _rev
      @h['_rev']
    end

    def id
      @h['_id']
    end

    def attachments
      (@h['_attachments'] || {}).keys.sort
    end

    def copy

      h = Rufus::Json.dup(@h)
      h.delete('_id')
      h.delete('_rev')

      self.class.new(h)
    end

    def save!

      raise ActiveRecord::RecordInvalid.new(self) unless valid?

      if @h['_id'].nil? && self.class._id_field

        i = if self.class._id_field.is_a?(String)
          self.send(self.class._id_field)
        else
          self.instance_eval &self.class._id_field
        end

        @h['_id'] = Doric::Couch.neutralize_id(i)
      end

      raise ActiveRecord::RecordInvalid.new(self) if @h['_id'].nil?

      r = Doric::Couch.put(@h)

      raise(SaveFailed.new(self.class.doric_type, _id)) unless r.nil?
    end

    #
    # methods required by ActiveModel (see test/unit/lint_mdmodel_test.rb

    def to_model
      self
    end

    def destroyed?

      @h['_destroyed'] == true
    end

    def new_record?

      @h['_id'].nil?
    end

    # Is used by <resource>_path and <resource>_url
    #
    def to_param

      @h['_id']
    end

    #
    # class methods

    def self.destroy_all

      get_all.each { |d| Doric::Couch.delete(d) }
    end

    def self.all

      get_all.collect { |d| self.new(d) }
    end

    def self.find (_id)

      doc = Doric::Couch.get(_id)

      raise Doric::Couch::NotFound.new(@doric_type, _id) unless doc

      self.new(doc)
    end

    protected

    def self.get_all

      path =
        "_design/doric/_view/by_doric_type?key=%22#{@doric_type}%22" +
        "&include_docs=true"

      # TODO : limit, skip

      Doric::Couch.get(path)['rows'].collect { |r| r['doc'] }
    end
  end
end
end

