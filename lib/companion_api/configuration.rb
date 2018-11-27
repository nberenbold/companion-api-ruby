module CompanionApi
  class Configuration
    attr_accessor :profile_directory

    attr_accessor :directory

    attr_accessor :debug

    def initialize
      @directory = File.join(File.dirname(__FILE__), '..', '..', 'config')
      @debug = false
    end
  end

  class << self
    def configure
      @config ||= Configuration.new
      yield @config
    end

    def config
      @config ||= Configuration.new
    end
  end
end
