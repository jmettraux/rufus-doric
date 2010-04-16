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

require 'cgi'


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

  # Returns a hash of all the types (models) seen/registered.
  #
  # For example, after this class definition :
  #
  #   class Concept < Rufus::Doric::Model
  #     db :doric
  #     doric_type :concepts
  #     _id_field :name
  #     property :name
  #   end
  #
  # this
  #
  #   p Rufus::Doric.types
  #
  # will yield
  #
  #   {"concepts"=>Concept}
  #
  def self.types

    (@types ||= {})
  end

  # Given a document (a Hash instance), will look at its 'doric_type' and
  # return an instance of a Rufus::Doric::Model or nil if there is
  # no model defined for that doric_type
  #
  def self.instantiate (doc)

    (types[doc['doric_type']].new(doc) rescue nil)
  end

  #
  # Classes extending that class have 1 Couch document per instance
  #
  class Model

    #extend ActiveModel::Naming
    include ActiveModel::Validations

    #
    # class 'helpers'

    def self.doric_type (rt=nil)

      if rt
        @doric_type = rt.to_s
        Rufus::Doric.types[@doric_type] = self
      end

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

      skey = key.is_a?(Array) ? key.join('_and_') : key

      instance_eval %{
        def by_#{skey} (val, opts={})
          by(#{key.inspect}, val, opts)
        end
      }
    end

    def self.text_index (*keys)

      @text_index = keys
    end

    include WithH
    include WithDb

    #--
    # constructor and instance methods
    #++

    attr_reader :h

    def initialize (doc={})

      @h = doc.inject(self.class.defaults.dup) { |h, (k, v)| h[k.to_s] = v; h }
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

      if @h['_id'].nil?

        if self.class._id_field

          @h['_id'] = if self.class._id_field.is_a?(String)
            self.send(self.class._id_field)
          else
            self.instance_eval(&self.class._id_field)
          end

        else

          @h['_id'] = generate_id
        end

        @h['_id'] = Rufus::Doric.neutralize_id(@h['_id'])
      end

      raise ActiveRecord::RecordInvalid.new(self) if @h['_id'].nil?

      r = db.put(@h)

      raise(SaveFailed.new(self.class.doric_type, _id)) unless r.nil?
    end

    #--
    # methods required by ActiveModel (see test/unit/ut_3_model_lint.rb)
    #++

    def to_key

      @h['_id'] ? [ @h['_id'] ] : nil
    end

    def to_model

      self
    end

    def destroyed?

      @h['_destroyed'] == true
    end

    def persisted?

      @h['_id'] != nil
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

    # Returns all the other objects in the same db that have a {something}_id
    # pointing to this object.
    #
    # For example, given
    #
    #   Person.new(
    #     :name => 'friedrisch', :vehicle_id => 'GE1212'
    #   ).save!
    #
    #   Book.new(
    #     :description => 'romance of the three kingdoms',
    #     :person_id => 'friedrisch'
    #   ).save!
    #   Computer.new(
    #     :description => 'black macbook',
    #     :person_id => 'friedrisch'
    #   ).save!
    #
    # then
    #
    #   f = Person.find('friedrisch')
    #   p f.belongings.map { |b| b.class.name }.sort)
    #
    # will print
    #
    #   ["Book", "Computer"]
    #
    def belongings

      dd = db.get('_design/doric') || DORIC_DESIGN_DOC

      s = self.class.doric_type.singularize

      view = "by_#{s}_id"

      unless dd['views'][view]

        dd['views'][view] = {
          'map' => %{
            function (doc) {
              if (doc.doric_type && doc.#{s}_id) emit(doc.#{s}_id, null);
            }
          }
        }
        db.put(dd)
      end

      i = Rufus::Doric.escape(_id)

      result = db.get("_design/doric/_view/#{view}?key=#{i}&include_docs=true")

      result['rows'].collect { |r| Rufus::Doric.instantiate(r['doc']) }
    end

    # All the association magic occur here, except for #belongings
    #
    def method_missing (m, *args)

      mm = m.to_s
      sm = mm.singularize
      multiple = (mm != sm)

      klass = sm.camelize
      klass = (self.class.const_get(klass) rescue nil)

      #return super unless klass

      id_method = multiple ? "#{sm}_ids" : "#{mm}_id"

      unless klass

        return super unless self.respond_to?(id_method)

        i = self.send(id_method)

        if multiple

          return [] unless i

          return i.collect { |ii|
            Rufus::Doric.instantiate(db.get(ii))
          }.select { |e|
            e != nil
          }
        end

        return Rufus::Doric.instantiate(db.get(i))
      end

      if multiple

        if self.respond_to?(id_method)

          ids = self.send(id_method)
          return [] unless ids

          ids.collect { |i| klass.find(i) }

        else

          by_method = "by_#{self.class.doric_type.singularize}_id"
          klass.send(by_method, self._id)
        end

      else

        return super unless self.respond_to?(id_method)

        klass.find(self.send(id_method))
      end
    end

    def hash
      h.hash
    end

    def == (other)
      return false unless other.class == self.class
      (h == other.h)
    end
    alias eql? ==

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

    # Well... Returns a map { 'word' => [ docid0, docid1 ] }
    #
    def self.texts (key=nil)

      return nil unless @text_index

      path = "#{design_path}/_view/text_index"
      path = "#{path}?key=%22#{key}%22" if key

      m = get_result(path, :text_index)

      m = m['rows'].inject({}) { |h, r| (h[r['key']] ||= []) << r['id']; h }

      key ? m[key] : m
    end

    protected

    # When there is no _id_field specified, this id generation routine
    # is used.
    #
    def generate_id

      s = [
        $$, Thread.current.object_id, self.object_id, Time.now.to_f.to_s
      ].join('_')

      "#{self.class.doric_type}__#{s}"
    end

    def self.func (body)
      %{
        function (doc) {
          if (doc.doric_type != '#{@doric_type}') return;
          #{body}
        }
      }
    end

    def self.put_design_doc (key=nil)

      # the 'all' view

      return db.put(DORIC_DESIGN_DOC) unless key

      # by_{key} views

      ddoc = db.get(design_path) || {
        '_id' => design_path,
        'views' => {}
      }

      if key == :text_index

        # I wish I could write keys.forEach(...) directly

        # do no word removing, it depends on languages, and can be
        # done on the client side

        ddoc['views']['text_index'] = {
          'map' => func(%{
            var keys = #{Rufus::Json.encode(@text_index)};
            for (var key in doc) {
              if (keys.indexOf(key) < 0) continue;
              if (doc[key] == undefined) continue;
              var words = doc[key].split(/[\s,;\.]/);
              words.forEach(function (word) {
                if (word != '') emit(word, null);
              });
            }
          })
        }

      elsif key.is_a?(Array)

        skey = key.join('_and_')
        keys = key.collect { |k| "doc['#{k}']" }.join(', ')

        ddoc['views']["by_#{skey}"] = {
          'map' => func(%{
            emit([#{keys}], null);
          })
        }

      else

        ddoc['views']["by_#{key}"] = {
          'map' => func(%{
            emit(doc['#{key}'], null);
          })
        }
      end

      db.put(ddoc)
    end

    def self.add_common_options (qs, opts)

      if limit = opts[:limit]
        qs << "limit=#{limit}"
      end
      if skip = opts[:skip]
        qs << "skip=#{skip}"
      end
      if opts[:descending]
        qs << "descending=true"
      end
      if opts[:inclusive_end]
        qs << "inclusive_end=true"
      end
    end

    def self.get_all (opts)

      qs = [ 'include_docs=true', "key=%22#{@doric_type}%22" ]

      add_common_options(qs, opts)

      path = "_design/doric/_view/by_doric_type?#{qs.join('&')}"

      result = get_result(path)

      result['rows'].collect { |r| r['doc'] }
    end

    def self.by (key, val, opts)

      qs = [ 'include_docs=true' ]

      if val.is_a?(Array) && ( ! key.is_a?(Array))

        st, en = val
        qs << "startkey=#{Rufus::Doric.escape(st)}" if st
        qs << "endkey=#{Rufus::Doric.escape(en)}" if en
      else

        qs << "key=#{Rufus::Doric.escape(val)}"
      end

      add_common_options(qs, opts)

      skey = key.is_a?(Array) ? key.join('_and_') : key

      path = "#{design_path}/_view/by_#{skey}?#{qs.join('&')}"

      result = get_result(path, key)

      result['rows'].collect { |r| self.new(r['doc']) }
    end

    # Ensures the necessary design_doc is loaded (if first query failed)
    # and then returns the raw result.
    #
    # Will raise if the design_doc can't be inserted (probably the underlying
    # db is missing).
    #
    def self.get_result (path, design_doc_key=nil)

      result = db.get(path)

      return result if result

      # insert design doc

      r = put_design_doc(design_doc_key)

      raise(
        "failed to insert 'any' design_doc in db '#{db.name}'"
      ) if r == true

      # re-get

      get_result(path, design_doc_key)
    end
  end
end
end

