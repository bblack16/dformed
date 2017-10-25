# DFormed

DFormed is a dynamic form generation framework written in Ruby and designed to be fully compatible with Opal. This means the code that writes the forms is the same on both the server and the client.

Forms are rendered using hash (or json) syntax, and return their values in a hash (or json) structure, as opposed to traditional HTML forms.

## Installation

__Important Note:__ This gem is not yet available on RubyGems.org. For now, clone this repo and use gem to build and install the gem or use the __specific_install__ gem to make life even easier.

Add this line to your application's Gemfile:

```ruby
gem 'dformed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dformed

## Usage

Usage documentation will come as this library enters the first stable release.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dformed. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
