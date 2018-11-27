module CompanionApi
  class Configuration
    attr_accessor :profile_directory

    attr_accessor :directory

    def initialize
      @directory = File.join(File.dirname(__FILE__), '..', '..', 'config')
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
