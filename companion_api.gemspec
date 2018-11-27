lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'companion_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'companion_api'
  spec.version       = CompanionApi::VERSION
  spec.authors       = ['Nils Berenbold']
  spec.email         = ['nils.berenbold@gmail.com']

  spec.summary       = 'A Wrapper for the Companion App Api'
  spec.description   = 'A Wrapper for the Companion App Api'
  spec.homepage      = 'https://xivapi.com'
  spec.license       = 'MIT'

  spec.metadata      = { "source_code_uri" => "https://github.com/nberenbold/companion-api-ruby" }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'activesupport', '~> 5'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.12.2'
  spec.add_dependency 'httpclient', '~> 2.8.3'
  spec.add_dependency 'nokogiri', '~> 1.8.5'
  spec.add_dependency 'pbkdf2-ruby', '~> 0.2.1'

  spec.required_ruby_version = '>= 2.2.0'
end
