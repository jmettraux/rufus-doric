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

#require 'rufus/doric/models'
#require 'rufus/doric/fixtures'


module Rufus
module Doric

  module Couch

    def self.url

      if defined?(Rails)
        return File.read(Rails.root.join('config', 'couch_url.txt')).strip
      end
      if File.exist?('couch_url.txt')
        return File.read('couch_url.txt').strip
      end

      'http://127.0.0.1:5984'
    end

    def self.couch

      Rufus::Jig::Couch.new(url)
    end

    def self.db (name, opts={})

      env = opts[:env]
      env ||= Rails.env if defined?(Rails)
      env ||= 'test'

      u = opts[:absolute] ? "#{url}/#{name}" : "#{url}/#{name}_#{env}"

      return u if opts[:url_only] || opts[:uo]

      Rufus::Jig::Couch.new(u)
    end

#    def self.purge! TODO (name, env)
#
#      result = Doric::Couch.get('_all_docs')
#
#      return unless result
#
#      result['rows'].each do |r|
#
#        _id = r['id']
#
#        next if _id.match(/^\_design\//)
#
#        _rev = r['value']['rev']
#
#        Doric::Couch.delete('_id' => _id, '_rev' => _rev)
#      end
#    end
  end
end
end

