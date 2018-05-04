# AppRevision

Returns the current application git commit SHA. Will look first in the APP_REVISION
environment variable, then in the REVISION file written by Capsitrano, then
in the Git history and lastly will return 'unknown' will be returned
 
# Installation

Add this line to your application's Gemfile:

```ruby
gem 'app_revision'
```

And then execute:

    $ bundle

## Usage

```ruby
AppRevision.current #=> "43ec44d89706ca948daea5124fdcc62694a87f43"
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WeTransfer/app_revision.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
