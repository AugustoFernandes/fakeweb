require File.join(File.dirname(__FILE__), "test_helper")
require 'fileutils'

class TestFakeWebGenerateFixture < Test::Unit::TestCase
  def setup
    @path = File.dirname(__FILE__) + "/fixtures/tmp"
    Dir.mkdir(@path)
  end

  def teardown
    FileUtils.rm_rf @path
    FakeWeb.allow_net_connect = true
  end

  def test_raise_error_when_path_invalid
    assert_raise RuntimeError do
      FakeWeb.generate_fixtures("invalid_path")
    end
  end

  def test_save_and_restore_one_fixture
    FakeWeb.generate_fixtures(@path)
    request = lambda { Net::HTTP.get_response URI.parse("http://www.google.com") }
    setup_basic_response_for_request
    real_response = request.call

    FakeWeb.register_fixtures(@path)
    FakeWeb.allow_net_connect = false
    assert_nothing_raised do
      assert_equal real_response.body, request.call.body
    end
  end

  def test_save_and_restore_multiple_fixtures
    FakeWeb.generate_fixtures(@path)
    setup_basic_response_for_request
    setup_basic_response_for_request :path => "/news/ipod.rss", :response_body => "iPod news"
    setup_basic_response_for_request :path => "/news/iphone.rss", :response_body => "iPhone news"
    requests = lambda do
      Net::HTTP.get_response URI.parse("http://www.google.com")
      Net::HTTP.get_response URI.parse("http://www.google.com/news/ipod.rss")
      Net::HTTP.get_response URI.parse("http://www.google.com/news/iphone.rss")
    end
    requests.call

    FakeWeb.register_fixtures(@path)
    FakeWeb.allow_net_connect = false
    assert_nothing_raised do
      requests.call
    end
  end

  def test_restoring_fixtures_stops_generating_fixtures
    FakeWeb.register_fixtures(@path)
    assert ! FakeWeb.generate_fixtures?
  end

  def test_generating_fixtures_allows_net_connections
    FakeWeb.allow_net_connect = false
    FakeWeb.generate_fixtures(@path)
    assert FakeWeb.allow_net_connect?
  end

  def test_compatibility_with_open_uri
    FakeWeb.generate_fixtures(@path)
    setup_basic_response_for_request
    assert_nothing_raised TypeError, "no marshal_dump is defined for class Proc" do
      open("http://www.google.com")
    end
  end
end
