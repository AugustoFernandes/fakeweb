module FakeWeb
  class Fixture
    attr_reader :path, :method, :uri, :response

    def self.register(path)
      Dir.glob("#{path}/*.fixture") do |name|
        fixture = YAML.load_file name
        fixture.register
      end
    end

    def initialize(path, method, uri, response)
      @path = path
      @method = method
      @uri = uri
      @response = response
    end

    def file_name
      @file_name ||= generate_file_name
    end

    def register
      FakeWeb.register_uri(method, uri, :response => response)
    end

    def save
      Dir.chdir path do
        File.open(file_name, 'w') do |f|
          f.write self.to_yaml
        end
      end
    end

    private

    def generate_file_name
      u = URI.parse(uri)
      path = u.path.gsub(/^\/$/, '').gsub(/\/$/, '').gsub('/', '-')
      identifier = Digest::MD5.hexdigest(uri)[0..6]
      "#{method.to_s.upcase}_#{u.host}#{path}_#{identifier}" + ".fixture"
    end
  end
end
