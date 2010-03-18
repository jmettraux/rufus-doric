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
  # One document containing a single value
  #
  class Value

    #
    # class 'helpers'

    def self.doc_id (_id=nil)

      @doc_id = _id.to_s if _id
      @doc_id
    end

    include WithDb

    #
    # constructor and instance methods

    attr_reader :h

    def initialize (h)

      @h = h.inject({}) { |hh, (k, v)| hh[k.to_s] = v; hh }
    end

    def value

      @h['value']
    end

    def save!

      doc = self.class.do_get(self.class.doc_id)
      doc ||= { '_id' => self.class.doc_id }

      doc['value'] = value

      db.put(doc)
    end

    #--
    # class methods
    #++

    def self.load

      self.new(do_get(doc_id))
    end

    protected

    def self.do_get (doc_id)

      db.get(doc_id) ||  { '_id' => doc_id, 'value' => nil }
    end
  end
end
end

