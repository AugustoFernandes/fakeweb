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

  def test_register_fixture_with_fake_web
    FakeWeb.expects(:register_uri).with(:get, "http://www.apple.com", :response => @response)
    @fixture.register
  end

  def test_file_name_without_path
    assert_equal @fixture.file_name, "GET_www.apple.com.fixture"
  end

  def test_file_name_with_path_and_querystring
    url = "http://www.apple.com/iphone/why-iphone/?q=iphone&other=i%20phone"
    fixture = FakeWeb::Fixture.new(@path, :get, url, stub)
    assert_equal fixture.file_name, "GET_www.apple.com-iphone-why-iphone.fixture"
  end

  def test_duplicate_file_name_increments_number_identifier
    File.new('GET_www.apple.com.fixture', 'w')
    assert_equal @fixture.file_name, "GET_www.apple.com_2.fixture"
    File.unlink('GET_www.apple.com.fixture')
  end

  def test_unique_file_name_when_integer_does_not_exist
    File.new('original.txt', 'w')

    fixture = FakeWeb::Fixture.allocate
    assert_equal fixture.send(:next_unique_file_name, "original.txt"), "original_2.txt"

    File.unlink('original.txt')
  end

  def test_unique_file_name_when_integer_exists
    File.new('original.txt', 'w')
    File.new('original_2.txt', 'w')

    fixture = FakeWeb::Fixture.allocate
    assert_equal fixture.send(:next_unique_file_name, "original.txt"), "original_3.txt"

    File.unlink('original.txt')
    File.unlink('original_2.txt')
  end

  def test_save
    file = stub
    File.expects(:open).with(@fixture.file_name, 'w').yields(file)
    file.expects(:write).with(@fixture.to_yaml)
    @fixture.save
  end
end
