require 'bundler/gem_tasks'
require 'rake/testtask'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wire_client/version'

GEM = 'wire_client'
VERSION = WireClient::VERSION

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'Build the sequel-seed gem'
task :build do
  sh %{#{FileUtils::RUBY} -S gem build #{GEM}.gemspec}
end

desc 'Release the sequel-seed gem to rubygems.org'
task release: :build do
  sh %{#{FileUtils::RUBY} -S gem push ./#{GEM}-#{VERSION}.gem}
end

task default: :test
