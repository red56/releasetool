# Releasetool

We use this tool to create releases and their documentation.
It makes versioned/numbered deployments easier to track.y
Would be nice if there was an engine to display the release notes in a rails app as well.

Not quite one-click release, but getting there...
## Installation

Add this line to your application's Gemfile:

    gem 'releasetool'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install releasetool

## Usage

### List existing tags

```release list```

### Prepare release notes and update version file

```release prepare -s OLD_RELEASE NEW_RELEASE_VERSION```


### Commit release notes and create tag

```release commit NEW_RELEASE_VERSION```

Currently this also commits config/initializers/00-version.rb as this is handy for our rails  projects. Might move this out into a config (or make check for the existings of , but only if need this to span non-rails projects.

### Push commits and tag

```release push NEW_RELEASE_VERSION```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
