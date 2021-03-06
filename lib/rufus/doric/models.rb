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

require 'active_model'
require 'active_record'

# there are more 'require' at the end of this file


module Rufus
module Doric

  def self.neutralize_id(s)

    s.to_s.strip.gsub(/[\.\s\/:;\*\\\+\?"#=&]/, '_')
  end

  def self.escape(o)

    CGI.escape(Rufus::Json.encode(o))
  end

  #
  # The including classes get two new class methods : h_reader and h_accessor
  # plus property as an alias to h_accessor
  #
  module WithH

    def self.included(target)

      def target.defaults

        @defaults || {}
      end

      def target.known_fields

        @known_fields
      end

      def target.h_reader(*names)

        names.each do |name|

          name = name.to_s

          (@known_fields ||= []) << name

          define_method(name) do
            @h[name]
          end
        end
      end

      def target.h_accessor(*names)

        default = nil

        if names.last.is_a?(Hash)
          opts = names.pop
          default = opts[:default]
        end

        h_reader(*names)

        names.each do |name|

          name = name.to_s

          (@defaults ||= {})[name] = default unless default.nil?

          define_method("#{name}=") do |v|
            @h[name] = v
          end
        end
      end

      def target.property(*names)

        h_accessor(*names)
      end
    end
  end

  #
  # The .db 'xyz' and #db methods
  #
  module WithDb

    def self.included(target)

      def target.db(dbname=nil, opts=nil)

        if dbname
          @db = dbname.to_s
          @db_opts = opts || {}
          return @db
        end

        Rufus::Doric.db(@db, @db_opts)
      end
    end

    def db

      self.class.db
    end

    protected

    def do_attach(doc, attname, data, opts={})

      extname = File.extname(attname)
      basename = File.basename(attname, extname)
      mime = ::MIME::Types.type_for(attname).first

      if data.is_a?(File)
        mime = ::MIME::Types.type_for(data.path).first
        data = data.read
      elsif data.is_a?(Array)
        data, mime = data
        mime = ::MIME::Types[mime].first
      end

      mime ||= (::MIME::Types[opts[:content_type]] || []).first

      raise ArgumentError.new("couldn't determine mime type") unless mime

      attname = "#{attname}.#{mime.extensions.first}" if extname == ''

      if doc['_rev'] # document has already been saved

        db.attach(
          doc['_id'], doc['_rev'], attname, data, :content_type => mime.to_s)

      else # document hasn't yet been saved, inline attachment...

        (doc['_attachments'] ||= {})[attname] = {
          'content_type' => mime.to_s,
          'data' => Base64.encode64(data).gsub(/[\r\n]/, '')
        }
      end
    end
  end

  #--
  # ERRORS
  #++

  # A common error class
  #
  class ModelError < StandardError

    attr_accessor :model_class, :_id

    def initialize(model_class, _id)
      @model_class = model_class
      @_id = _id
    end

    def to_s
      "#{@model_class}/#{@_id}"
    end
  end

  class NotFound < ModelError; end
  class SaveFailed < ModelError; end
end
end

require 'rufus/doric/model'
require 'rufus/doric/one_doc_model'

require 'rufus/doric/value'

