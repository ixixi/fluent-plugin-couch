# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: fluent-plugin-couch 0.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent-plugin-couch".freeze
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yuri Odagiri".freeze]
  s.date = "2017-02-07"
  s.email = "ixixizko@gmail.com".freeze
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
  s.homepage = "http://github.com/ixixi/fluent-plugin-couch".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "CouchDB output plugin for Fluentd event collector".freeze
  s.test_files = ["test/test_out_couch.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fluentd>.freeze, ["< 2", ">= 0.14.0"])
      s.add_runtime_dependency(%q<couchrest>.freeze, ["~> 1.1.2"])
      s.add_runtime_dependency(%q<jsonpath>.freeze, ["~> 0.4.2"])
      s.add_development_dependency(%q<rake>, [">= 12.0.0"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.2.0"])
    else
      s.add_dependency(%q<fluentd>.freeze, ["< 2", ">= 0.14.0"])
      s.add_dependency(%q<couchrest>.freeze, ["~> 1.1.2"])
      s.add_dependency(%q<jsonpath>.freeze, ["~> 0.4.2"])
      s.add_development_dependency(%q<rake>, [">= 12.0.0"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.2.0"])
    end
  else
    s.add_dependency(%q<fluentd>.freeze, ["< 2", ">= 0.14.0"])
    s.add_dependency(%q<couchrest>.freeze, ["~> 1.1.2"])
    s.add_dependency(%q<jsonpath>.freeze, ["~> 0.4.2"])
    s.add_development_dependency(%q<rake>, [">= 12.0.0"])
    s.add_development_dependency(%q<test-unit>, ["~> 3.2.0"])
  end
end
