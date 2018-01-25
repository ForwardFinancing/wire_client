# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wire_client/version'

Gem::Specification.new do |spec|
  spec.name = 'wire_client'
  spec.version = WireClient::VERSION
  spec.authors = [
    'Ewerton Carlos Assis',
    'Forward Financing LLC'
  ]
  spec.email = [
    'eassis@forwardfinancing.com'
  ]
  spec.licenses = ['MIT']

  spec.summary = %q{ Adapter to interact with Wire Transfer service providers }
  spec.homepage = 'https://github.com/ForwardFinancing/wire_client'

  spec.files = `git ls-files -z`.split(/\x0/)
                                .reject do |f|
                                  f.match(%r{^(test|spec|features)/})
                                end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = [
    'lib'
  ]

  # ach_client library
  spec.add_dependency 'ach_client', '~> 0'

  # Handy ruby behavior from rails
  spec.add_dependency 'activesupport'

  # SEPA King, for the ISO 20022 Credit Transfer Initiation (pain.001.001.03 format)
  spec.add_dependency 'sepa_king'

  # SFTP client (for Bank providers)
  spec.add_dependency 'net-sftp'

  # Asynchronocity w/out extra infrastucture dependency (database/redis)
  spec.add_dependency 'sucker_punch', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'bundler-audit'
end
