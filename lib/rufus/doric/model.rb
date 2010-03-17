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

#require 'cgi'


module Rufus
module Doric

  DORIC_DESIGN_DOC = {
    '_id' => '_design/doric',
    'views' => {
      'by_doric_type' => {
        'map' => %{
          function(doc) {
            if (doc.doric_type) emit(doc.doric_type, null);
          }
        }
      }
    }
  }

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

    def self.view_by (key)

      @keys ||= []
      @keys << key.to_s

      instance_eval %{
        def by_#{key} (val, opts={})
          by('#{key}', val, opts)
        end
      }
    end

    include WithH
    include WithDb

    #--
    # constructor and instance methods
    #++

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

        @h['_id'] = Rufus::Doric.neutralize_id(i)
      end

      raise ActiveRecord::RecordInvalid.new(self) if @h['_id'].nil?

      r = db.put(@h)

      raise(SaveFailed.new(self.class.doric_type, _id)) unless r.nil?
    end

    #--
    # methods required by ActiveModel (see test/unit/lint_mdmodel_test.rb
    #++

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

    def delete

      @h['_destroyed'] = true
      db.delete(@h)

      # TODO : raise when the delete fails
    end

    def destroy

      delete
    end

    #--
    # class methods
    #++

    def self.destroy_all

      get_all({}).each { |d| db.delete(d) }
    end

    def self.all (opts={})

      get_all(opts).collect { |d| self.new(d) }
    end

    def self.find (_id)

      doc = db.get(_id)

      raise Rufus::Doric::NotFound.new(@doric_type, _id) unless doc

      self.new(doc)
    end

    def self.design_path

      name = self.to_s.downcase
      name = name.gsub(/::/, '__')

      "_design/doric_#{name}"
    end

    protected

    def self.put_design_doc (key=nil)

      # the 'all' view

      unless key
        db.put(DORIC_DESIGN_DOC)
        return
      end

      # by_{key} views

      x = {
        '_id' => '_design/doric',
        'views' => {
          'by_doric_type' => {
            'map' => %{
              function(doc) {
                if (doc.doric_type) emit(doc.doric_type, null);
              }
            }
          }
        }
      }

      ddoc = db.get(design_path) || {
        '_id' => design_path,
        'views' => {}
      }

      ddoc['views']["by_#{key}"] = {
        'map' => %{
          function(doc) {
            if (doc.doric_type == '#{@doric_type}') {
              emit(doc['#{key}'], null);
            }
          }
        }
      }

      db.put(ddoc)
    end

    def self.get_all (opts)

      # TODO : limit, skip (opts)

      path =
        "_design/doric/_view/by_doric_type?key=%22#{@doric_type}%22" +
        "&include_docs=true"

      result = db.get(path)

      unless result

        # insert design doc

        put_design_doc
        return get_all(opts)
      end

      result['rows'].collect { |r| r['doc'] }
    end

    def self.by (key, val, opts)

      # TODO : limit, skip (opts)

      #v = Rufus::Json.encode(val)
      #v = CGI.escape(v)
      v = "%22#{val}%22"

      path = "#{design_path}/_view/by_#{key}?key=#{v}&include_docs=true"

      result = db.get(path)

      unless result
        put_design_doc(key)
        return by(key, val, opts)
      end

      result['rows'].collect { |r| r['doc'] }
    end
  end
end
end

