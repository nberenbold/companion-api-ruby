source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'pbkdf2', github: 'emerose/pbkdf2-ruby', ref: 'f9a337e3559de7e61792f2c761a91ea57d53e095'

group :test do
  gem 'rubocop', '0.60.0'
  gem 'rubocop-rspec', require: false
end

# Specify your gem's dependencies in companion_api.gemspec
gemspec
