# -*- encoding: utf-8 -*-
# stub: rails-erd 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-erd".freeze
  s.version = "2.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rolf Timmermans".freeze, "Kerri Miller".freeze]
  s.date = "1980-01-02"
  s.description = "Automatically generate an entity-relationship diagram (ERD) for your Rails models.".freeze
  s.email = ["r.timmermans@voormedia.com".freeze, "kerrizor@kerrizor.com".freeze]
  s.executables = ["erd".freeze]
  s.files = ["bin/erd".freeze]
  s.homepage = "https://github.com/voormedia/rails-erd".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "4.0.10".freeze
  s.summary = "Entity-relationship diagram for your Rails models.".freeze

  s.installed_by_version = "3.6.7".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 7.0".freeze])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 7.0".freeze])
  s.add_runtime_dependency(%q<choice>.freeze, ["~> 0.2.0".freeze])
  s.add_runtime_dependency(%q<ostruct>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<ruby-graphviz>.freeze, ["~> 1.2".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry-nav>.freeze, [">= 0".freeze])
end
