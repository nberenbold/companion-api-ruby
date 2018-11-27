require 'bundler/setup'
require 'companion_api'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    directory = File.join(File.dirname(__FILE__), '..', 'tmp')
    FileUtils.mkdir(directory) unless File.exist?(directory)

    CompanionApi.configure do |config|
      config.profile_directory = directory
      config.debug = true
    end
  end
end
