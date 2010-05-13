
#
# testing rufus-doric
#
# Thu May 13 08:53:01 JST 2010
#

require File.join(File.dirname(__FILE__), 'base')

require 'rufus/doric'


class Thing < Rufus::Doric::Model

  db :doric

  doric_type :things
  _id_field :name
  h_accessor :name
end

class Folder < Rufus::Doric::Model

  db :doric

  doric_type :folders
  _id_field :name
  h_accessor :name

  attachment :icon
end


class UtModelAndAttachmentsTest < Test::Unit::TestCase

  def setup

    Rufus::Doric.db('doric').delete('.')
    Rufus::Doric.db('doric').put('.')

    Rufus::Doric.db('doric').http.cache.clear
      # CouchDB feeds the same etags for views, even after a db has
      # been deleted and put back, so have to do that 'forgetting'
  end

  #def teardown
  #end

  def test_attach_pre_save

    txt = File.read(__FILE__)

    t = Thing.new('name' => 'that_piece_of_code')
    t.attach('this_code.txt', txt)
    t.save!

    t = Thing.find('that_piece_of_code')

    assert_equal [ 'this_code.txt' ], t.attachments
    assert_equal txt, t.db.get('that_piece_of_code/this_code.txt')
  end

  def test_attach

    txt = File.read(__FILE__)

    t = Thing.new('name' => 'piece_of_code')
    t.save!

    t = Thing.find('piece_of_code')

    assert_equal [], t.attachments

    t.attach('code.txt', txt)

    t = Thing.find('piece_of_code')

    assert_equal [ 'code.txt' ], t.attachments
    assert_equal txt, t.db.get('piece_of_code/code.txt')
  end

  def test_detect_and_attach_pre_save

    t = Thing.new('name' => 'al_vetro_pre')
    t.attach('result', File.new(path_to('al_vetro.png')))
    t.save!

    t = Thing.find('al_vetro_pre')

    assert_equal [ 'result.png' ], t.attachments
    assert_equal "\x89PNG\r\n\x1A", t.read('result')[0, 7]
    assert_equal "\x89PNG\r\n\x1A", t.read('result.png')[0, 7]
  end

  def test_detect_and_attach

    t = Thing.new('name' => 'al_vetro')
    t.save!

    t = Thing.find('al_vetro')
    t.attach('result', File.new(path_to('al_vetro.png')))

    t = Thing.find('al_vetro')

    assert_equal [ 'result.png' ], t.attachments
    assert_equal "\x89PNG\r\n\x1A", t.read('result')[0, 7]
    assert_equal "\x89PNG\r\n\x1A", t.read('result.png')[0, 7]
  end

  def test_detach

    t = Thing.new('name' => 'ms_excel')
    t.save!

    t = Thing.find('ms_excel')
    t.attach('code.txt', File.read(__FILE__))

    t = Thing.find('ms_excel')

    assert_equal [ 'code.txt' ], t.attachments

    t.detach('code.txt')

    assert_equal [], Thing.find('ms_excel').attachments
  end

  def test_named_attachment_pre_save

    f = Folder.new('name' => 'summer')
    f.icon = File.new(File.join(File.dirname(__FILE__), 'al_vetro.png'))
    f.save!

    f = Folder.find('summer')
    assert_equal [ 'icon.png' ], f.attachments

    assert_equal "\x89PNG\r\n\x1A", f.icon[0, 7]
  end

  def test_named_attachment

    f = Folder.new('name' => 'winter')
    f.save!

    f = Folder.find('winter')
    f.icon = File.new(path_to('al_vetro.png'))

    f = Folder.find('winter')
    assert_equal [ 'icon.png' ], f.attachments

    assert_equal "\x89PNG\r\n\x1A", f.icon[0, 7]
  end

  def test_read

    t = Thing.new('name' => 'some_thing')
    t.attach('toto.txt', File.read(__FILE__))
    t.save!

    t = Thing.find('some_thing')

    assert_equal "\n#\n# testing r", t.read('toto.txt')[0, 14]
    assert_equal "\n#\n# testing r", t.read('toto')[0, 14]
    assert_equal "\n#\n# testing r", t.read(:toto)[0, 14]
  end

  def test_string_attachment_missing_content_type

    assert_raise ArgumentError do
      f = Folder.new('name' => 'spring')
      f.icon = File.read(path_to('al_vetro.png'))
    end
  end

  def test_string_attachment

    f = Folder.new('name' => 'spring')
    f.icon = [ File.read(path_to('al_vetro.png')), 'text/plain' ]
    f.save!

    f = Folder.find('spring')

    assert_equal [ 'icon.txt' ], f.attachments
  end

  protected

  def path_to (local_item)

    File.join(File.dirname(__FILE__), local_item)
  end
end

