require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebFixture < Test::Unit::TestCase
  def setup
    @response = Net::HTTPOK.new("1.1", "200", "OK")
    @path = "."
    @fixture = FakeWeb::Fixture.new(@path, :get, "http://www.apple.com", @response)
  end

  def test_register_fixtures_in_path
    fixture = mock(:register => true)
    YAML.expects(:load_file).with('file').returns(fixture)
    Dir.expects(:glob).yields('file')
    FakeWeb::Fixture.register(@path)
  end

  def test_file_name_without_path
    identifier = Digest::MD5.hexdigest("http://www.apple.com")[0..6]
    assert_equal @fixture.file_name, "GET_www.apple.com_#{identifier}.fixture"
  end

  def test_file_name_with_path_and_querystring
    url = "http://www.apple.com/iphone/why-iphone/?q=iphone&other=i%20phone"
    identifier = Digest::MD5.hexdigest(url)[0..6]
    fixture = FakeWeb::Fixture.new(@path, :get, url, stub)
    assert_equal fixture.file_name, "GET_www.apple.com-iphone-why-iphone_#{identifier}.fixture"
  end

  def test_register_fixture_with_fake_web
    FakeWeb.expects(:register_uri).with(:get, "http://www.apple.com", :response => @response)
    @fixture.register
  end

  def test_save
    file = stub
    File.expects(:open).with(@fixture.file_name, 'w').yields(file)
    file.expects(:write).with(@fixture.to_yaml)
    @fixture.save
  end
end
