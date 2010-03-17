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

require 'mime/types'
require 'rufus-jig'


module Rufus
module Doric

  module Fixtures

    ATT_TYPES = %w[ .png .gif .jpg .jpeg .pdf ]

    # Given a fixture tree
    #
    # test/
    # `-- fixtures
    #     `-- test
    #         `-- doric
    #             |-- 69247b__picture.jpg
    #             |-- 69249__picture.jpg
    #             |-- product0.json
    #             |-- product1.json
    #             |-- users.json
    #             |-- users__jami.png
    #             `-- users__john.jpg
    #
    # this
    #
    #   require 'rufus/doric/fixtures'
    #   Rufus::Doric::Fixtures.load('http://127.0.0.1:5984', 'fixtures/test')
    #
    # will load the documents (and their attachements)
    # into http://127.0.0.1:5984/doric_test
    #
    #
    # == options
    #
    # === :env
    #
    # by default env is set to the name of the fixture root dir ('test'
    # in our example above)
    #
    # === :create
    #
    # when true and the db doesn't exist, will create it
    #
    # === :purge
    #
    # when true will delete all docs before inserting, implies :create => true
    #
    # === :overwrite
    #
    # when true, if a doc is already present, will overwrite it
    #
    # === :db
    #
    # takes a String. Sets the name of the Couch database absolutely
    #
    # === :verbose
    #
    # when true, turns verbose. Here is an example output :
    #
    #   .couch is at http://127.0.0.1:5984
    #   .fixtures are at test/fixtures/test
    #   .env is 'test'
    #   .opts are {:create=>true, :purge=>true, :verbose=>true}
    #    .purged db at http://127.0.0.1:5984/doric_test
    #    .loading into http://127.0.0.1:5984/doric_test
    #     .reading test/fixtures/test/doric/product0.json
    #      .inserting at http://127.0.0.1:5984/doric_test/69249
    #     .reading test/fixtures/test/doric/product1.json
    #      .inserting at http://127.0.0.1:5984/doric_test/69247b
    #     .reading test/fixtures/test/doric/users.json
    #      .inserting at http://127.0.0.1:5984/doric_test/users
    #    .loading attachments into http://127.0.0.1:5984/doric_test
    #     .reading test/fixtures/test/doric/69247b__picture.jpg
    #      .inserting at http://127.0.0.1:5984/doric_test/69247b/picture.jpg
    #     .reading test/fixtures/test/doric/69249__picture.jpg
    #      .inserting at http://127.0.0.1:5984/doric_test/69249/picture.jpg
    #     .reading test/fixtures/test/doric/users__jami.png
    #      .inserting at http://127.0.0.1:5984/doric_test/users/jami.png
    #     .reading test/fixtures/test/doric/users__john.jpg
    #      .inserting at http://127.0.0.1:5984/doric_test/users/john.jpg
    #
    def self.load (couch_uri, path, opts={})

      env = opts[:env] || File.split(path).last
      verbose = opts[:verbose]

      if verbose
        puts ".couch is at #{couch_uri}"
        puts ".fixtures are at #{path}"
        puts ".env is '#{env}'"
        puts ".opts are #{opts.inspect}"
      end

      Dir[File.join(path, '*')].each do |dbpath|

        dbname = File.split(dbpath).last

        db_uri = "#{couch_uri}/#{dbname}_#{env}"

        if dbn = opts[:db]
          db_uri = "#{couch_uri}/#{dbn}"
        end

        db = Rufus::Jig::Couch.new(db_uri)

        if db.get('.').nil?
          if opts[:create] || opts[:purge]
            db.put('.')
            puts " .created db at #{db_uri}" if verbose
          else
            raise(ArgumentError.new("db #{db_uri} doesn't exist"))
          end
        else
          if opts[:purge]
            db.delete('.')
            db.put('.')
            puts " .purged db at #{db_uri}" if verbose
          end
        end

        puts " .loading into #{db_uri}" if verbose

        #
        # load documents

        Dir[File.join(dbpath, '*.json')].each do |docpath|

          puts "  .reading ...#{docpath[-60..-1]}" if verbose

          doc = Rufus::Json.decode(File.read(docpath))

          current_doc = db.get(doc['_id'])

          if current_doc && (not opts[:overwrite])
            puts "   .skipping #{doc['_id']} (:overwrite == false)"
            next
          end

          db.delete(current_doc) if current_doc

          puts "   .inserting at #{db_uri}/#{doc['_id']}" if verbose
          db.put(doc)
        end

        #
        # load attachments

        puts " .loading attachments into #{db_uri}" if verbose

        Dir[File.join(dbpath, '*')].each do |attpath|

          next if attpath.match(/\.json$/)

          ext = File.extname(attpath).downcase

          next unless ATT_TYPES.include?(ext)

          docid, attname = File.basename(attpath).split('__')

          puts "  .reading ...#{attpath[-60..-1]}" if verbose

          current_att = db.get(File.join(docid, attname))

          if current_att && (not opts[:overwrite])
            puts "   .skipping #{docid}/#{attname} (:overwrite == false)"
            next
          end

          doc = db.get(docid)

          raise(
            ArgumentError.new("cannot attach to missing document #{docid}")
          ) unless doc

          data = File.read(attpath)

          puts "   .inserting at #{db_uri}/#{docid}/#{attname}" if verbose

          db.attach(
            doc, attname, data,
            :content_type => MIME::Types.type_for(attname).first.to_s)
        end
      end
    end
  end

end
end

