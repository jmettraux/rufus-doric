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
  # The models built on top of this class store all their instances
  # in one Couch document.
  #
  class OneDocModel

    include ActiveModel::Validations

    #
    # class 'helpers'

    def self.doc_id(_id=nil)

      @doc_id = _id.to_s if _id
      @doc_id
    end

    include WithH
    include WithDb

    #
    # constructor and instance methods

    attr_reader :h
    attr_reader :attachment

    def initialize(h, doc=nil)

      @h = h.inject(Rufus::Json.dup(self.class.defaults)) { |hh, (k, v)|
        hh[k.to_s] = v; hh
      }

      if doc && atts = doc['_attachments']

        @attachment, details = atts.find { |k, v|
          File.basename(k, File.extname(k)) == @h['_id']
        }
      end
    end

    def _id

      @h['_id']
    end

    def save!

      raise ActiveRecord::RecordInvalid.new(self) unless valid?

      doc = self.class.do_get(self.class.doc_id)
      doc[self.class.doc_id][@h['_id']] = @h

      db.put(doc)
    end

    def delete

      doc = self.class.do_get(self.class.doc_id)
      doc[self.class.doc_id].delete(@h['_id'])

      # TODO : raise when the put fails

      db.put(doc)
    end

    def destroy

      delete
    end

    # Given a model named User, some usage examples :
    #
    #   u = User.find('john')
    #   u.attach(File.read('avatar.png', :content_type => 'image/png'
    #   u.attach([ File.read('avatar.png', 'image/png' ])
    #
    def attach(data, opts={})

      #def do_attach(doc, attname, data, opts={})
      do_attach(db.get(self.class.doc_id), _id, data, opts)
    end

    #--
    # class methods
    #++

    def self.create!(h)

      self.new(h).save!
    end

    def self.all

      doc = do_get(@doc_id)

      doc[@doc_id].values.collect { |h| self.new(h, doc) }
    end

    def self.destroy_all

      doc = db.get(@doc_id)
      db.delete(doc) if doc
    end

    def self.find(_id)

      doc = do_get(@doc_id)

      h = doc[@doc_id][_id]
      h ? self.new(h, doc) : nil
    end

    #--
    # methods required by ActiveModel (see test/unit/ut_5_one_doc_model_lint.rb
    #++

    def to_model

      self
    end

    def persisted?

      true
    end

    def to_key

      @h['_id'] ? [ @h['_id'] ] : nil
    end

    # Is used by <resource>_path and <resource>_url
    #
    def to_param

      @h['_id']
    end

    protected

    def self.do_get(doc_id)

      db.get(doc_id) ||  { '_id' => doc_id, doc_id => {} }
    end
  end
end
end

