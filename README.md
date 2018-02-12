[![Codeship Status for ForwardFinancing/wire_client](https://app.codeship.com/projects/80539010-e9b6-0135-7649-4a1e2141a6e6/status?branch=master)](https://app.codeship.com/projects/269959)
[![Code Climate](https://api.codeclimate.com/v1/badges/055840fb4eaf9e44ec80/maintainability)](https://codeclimate.com/repos/5a6a6058396682027c0028f6/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/055840fb4eaf9e44ec80/test_coverage)](https://codeclimate.com/repos/5a6a6058396682027c0028f6/test_coverage)

# WireClient

> Implementation of ISO 20022 payment initiation (pain) messages and bank providers for wire transfers

## Overview

The WireClient gem provides a common interface for working with a variety of Wire Transfer providers
and building ISO 20022 payment initiation (pain) messages &mdash; currently, only `pain.001.001.03`
and `pain.008.001.02` messages are supported.

This is a fork of the [`sepa_king`](https://github.com/salesking/sepa_king) Ruby gem. Our main purpose
is to create a flexible solution appliable to the American financial system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wire_client'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself:

```sh
$ gem install wire_client
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `bundle exec rake test` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ForwardFinancing/wire_client.
