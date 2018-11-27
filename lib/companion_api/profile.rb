module CompanionApi
  class Profile
    attr_accessor :profile_name
    attr_accessor :file
    attr_accessor :settings

    def initialize(profile_name)
      @file = File.join(CompanionApi.config.profile_directory, "#{profile_name}.json")
      @settings = {}

      load
    end

    def set(key, value)
      @settings[key.to_sym] = value
      save
    end

    def get(key)
      @settings[key.to_sym]
    end

    protected

    def load
      return save unless File.exist?(@file)

      @settings = JSON.parse(open(@file).read, symbolize_names: true)
    end

    def save
      File.open(@file, 'w') do |f|
        f.write(@settings.to_json)
      end
    end
  end
end
