# CompanionApi

This gem provides a wrapper to the SE Companion App Api, right now it only supports the marketplace, you are free to add the other endpoints.

This gem is basically a rewrite of the php Version from Vekien (https://github.com/xivapi/companion-php)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'companion_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install companion_api

## Usage

```ruby
CompanionApi.configure do |config|
  config.profile_directory = "PATH" # Here are the profiles stored for later use
  config.logger = Logger.new("PATH")
  config.debug = false
end
```

For rails put initialization into config/initializers/companion_api.rb

```ruby
CompanionApi.configure do |config|
  config.profile_directory = Rails.root.join("tmp", "profiles").to_s # Here are the profiles stored for later use
  config.logger = Logger.new(Rails.root.join("log", "companion.log"))
  config.debug = false
end
```

### Login

```ruby
api = CompanionApi::Base.new('test_profile')
api.login!("USERNAME", "PASSWORD")
```

afterwards you are able to select a character and use it for the marketplace Api

The token you'll receive is valid for 24 hours, if the token expires a custom ```CompanionApi::TokenExpiredError``` is raised

```ruby
characters = api.login.characters
api.login.select_character(characters.first['cid'])
```

you can check if you are logged in to a character by using ```api.loggedin?```

### Marketplace

```ruby
# load a earth shards
result = api.market.market_listings_by_category(58)
>> result["items"]
 
result = api.market.item_market_listings(5)
>> result["entries"]

# load only hq results
result = api.market.item_market_listings(23_769, hq: true)
>> result["entriesHq"]

result = api.market.transaction_history(5)
>> result["history"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nberenbold/companion-api-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
