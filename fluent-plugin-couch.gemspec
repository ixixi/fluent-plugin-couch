# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: fluent-plugin-couch 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent-plugin-couch"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Yuri Odagiri"]
  s.date = "2017-05-26"
  s.email = "ixixizko@gmail.com"
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "AUTHORS",
    "Rakefile",
    "VERSION",
    "lib/fluent/plugin/out_couch.rb",
    "test/test_out_couch.rb"
  ]
   s.homepage = "http://github.com/ixixi/fluent-plugin-couch"
  s.rubygems_version = "2.4.1"
  s.summary = "CouchDB output plugin for Fluentd event collector"
  s.test_files = ["test/test_out_couch.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fluentd>, ["< 2", ">= 0.10.0"])
      s.add_runtime_dependency(%q<couchrest>, ["~> 1.1.2"])
      s.add_runtime_dependency(%q<jsonpath>, ["~> 0.4.2"])
    else
      s.add_dependency(%q<fluentd>, ["< 2", ">= 0.10.0"])
      s.add_dependency(%q<couchrest>, ["~> 1.1.2"])
      s.add_dependency(%q<jsonpath>, ["~> 0.4.2"])
    end
  else
    s.add_dependency(%q<fluentd>, ["< 2", ">= 0.10.0"])
    s.add_dependency(%q<couchrest>, ["~> 1.1.2"])
    s.add_dependency(%q<jsonpath>, ["~> 0.4.2"])
  end
end

