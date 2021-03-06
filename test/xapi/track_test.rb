require_relative 'test_helper'
require_relative '../../lib/xapi'

class TrackTest < Minitest::Test
  def test_default_track
    track = Xapi::Track.new('fake', FIXTURE_PATH)

    assert track.exists?, "track 'fake' not found"
    assert track.active?, "track 'fake' inactive"
    assert_equal "Fake", track.language
    assert_equal "https://github.com/exercism/xfake", track.repository
    assert_equal 5, track.checklist_issue
    assert_equal nil, track.gitter

    problems = %w(hello-world one two three)
    assert_equal problems, track.problems
    assert_equal ["apple"], track.foregone
    assert_equal ["dog"], track.deprecated
    assert_equal problems, track.implementations.map {|implementation|
      implementation.problem.slug
    }

    slugs = %w(hello-world one two three apple dog)
    assert_equal slugs, track.slugs

    # default test pattern
    files = [
      "file.ext",
      "test.ext",
      "file_test.ext",
      "TestFile.ext",
      "spec.ext",
      "sub/test/file.ext",
      "sub/TestDir/file.ext",
    ]
    assert_equal %w(file.ext spec.ext), files.reject {|f|
      f =~ track.test_pattern
    }

    docs = {
      "about" => "Language Information\n",
      "installation" => "Installing\n",
      "tests" => "Running\n",
      "learning" => "Learning Fake!\n",
      "resources" => "Resources\n",
    }
    assert_equal docs, track.docs

    img = track.img('test.png')
    assert img.exists?, "image test.png cannot be found"
    assert_equal :png, img.type
    assert_equal "./test/fixtures/tracks/fake/docs/img/test.png", img.path

    img = track.img('nope.png')
    refute img.exists?, "should not have a nope.png"
  end

  def test_doc_format
    assert_equal "org", Xapi::Track.new('fake', FIXTURE_PATH).doc_format
    assert_equal "md", Xapi::Track.new('fruit', FIXTURE_PATH).doc_format
    assert_equal "md", Xapi::Track.new('jewels', FIXTURE_PATH).doc_format # no docs dir
  end

  def test_track_with_gitter_room
    track = Xapi::Track.new('fruit', FIXTURE_PATH)

    assert_equal "xfruit", track.gitter
  end

  def test_track_with_default_checklist_issue
    track = Xapi::Track.new('fruit', FIXTURE_PATH)

    assert_equal 1, track.checklist_issue
  end

  def test_custom_test_pattern
    track = Xapi::Track.new('fruit', FIXTURE_PATH)

    files = [
      "file.ext",
      "test.ext",
      "file.tst",
      "sub/dir/file.ext",
      "sub/dir/file.tst",
    ]
    assert_equal %w(file.tst sub/dir/file.tst), files.select {|f|
      f =~ track.test_pattern
    }
  end

  def test_unknown_track
    refute Xapi::Track.new('nope', FIXTURE_PATH).exists?, "unexpected track 'nope'"
  end
end
