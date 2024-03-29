# Releasetool

We use this tool to create releases and their documentation.
It makes versioned/numbered deployments easier to track.
Would possibly be nice if there was an engine to display the release notes in a rails app as well.

Not quite one-click release, but getting there...

## Installation

Add this line to your application's Gemfile:

    gem 'releasetool'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install releasetool

## Usage

```release help```

### List existing tags

```release list```

### Start the release -- generate release notes and update version file

```release start```

This will start a new patch verison, but you can start minor or major 

```release start --minor```

```release start --major```

Or you can specify the new verison. 

```release start NEW_VERSION```

All of these will use the most recent tag as the previous version. If you don't have a most recent tag, or you want to start from something else use:

```release start -s PREVIOUS_VERSION NEW_VERSION```

Now edit the created release notes (release_notes/NEW_VERSION.md)

### Commit release notes

```release commit```

Currently this also commits config/initializers/00-version.rb as this is handy for our rails  projects. Might move this out into a config (or make check for the existings of , but only if need this to span non-rails projects.

### Create a named tag (for later reference using release list)

```release tag```

It will ask for a one-line summary of the release (full details are in the release notes)

### Push commits and tag

```release push```


## Testing

The tests work on a known-good repo stored in `spec/fixtures/example_with_releases.tar`. To recreate this:
```
mkdir -p spec/fixtures/example_with_releases
cd spec/fixtures/example_with_releases && tar -xvf ../example_with_releases.tar  && cd -
```

then you can tweak it and save it back with:
```
cd spec/fixtures/example_with_releases && tar -cvf ../example_with_releases.tar . && cd -
```

ditto for other one with config

cd spec/fixtures/example_with_releases && tar -cvf ../example_with_releases.tar . && cd -

## Configuration

If you want it to automatically update the version number in a string then set the environment variable
 `RELEASETOOL_VERSION_FILE`, eg. `export RELEASETOOL_VERSION_FILE=./lib/releasetool.rb`. By default this is configured to config/initializers/00-version.rb (useful for rails projects).

If you want to run something after `release start` or after `release commit` then generate a hooks file:

    release init

which will generate a file at `config/releasetool/hooks.rb` which you can adjust.

## Contributing

see testing above

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Releasing

For releasing the releasetool itself we need to set an environment variable `export RELEASETOOL_VERSION_FILE=./lib/releasetool/version.rb`

and after doing `release push`, we do 
`rake release` to release the gem
