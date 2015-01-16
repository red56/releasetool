# Releasetool

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'releasetool'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install releasetool

## Usage

### Prepare release notes

```release prepare -s OLD_RELEASE NEW_RELEASE_VERSION```

### Commit release notes

```release commit```

Currently this also commits config/initializers/00-version.rb as this is handy for our rails projects. Might move this
 out into a config, but only if need this to span non-rails projects.
  
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
