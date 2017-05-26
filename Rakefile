require 'rake'
require 'rake/testtask'
require 'rake/clean'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "fluent-plugin-couch"
    gemspec.summary = "CouchDB output plugin for Fluentd event collector"
    gemspec.author = "Yuri Odagiri"
    gemspec.email = "ixixizko@gmail.com"
    gemspec.homepage = "http://github.com/ixixi/fluent-plugin-couch"
    gemspec.has_rdoc = false
    gemspec.require_paths = ["lib"]
    gemspec.add_dependency "fluentd", [">= 0.14.0", "< 2"]
    gemspec.add_dependency "couchrest", "~> 1.1.2"
    gemspec.add_dependency "jsonpath", "~> 0.4.2"
    gemspec.test_files = Dir["test/**/*.rb"]
    gemspec.files = Dir["lib/**/*", "test/**/*.rb"] + %w[VERSION AUTHORS Rakefile]
    gemspec.executables = []
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/test_*.rb"].sort
  t.ruby_opts = ['-rubygems'] if defined? Gem
  t.ruby_opts << '-I.'
end

task :default => [:build]
