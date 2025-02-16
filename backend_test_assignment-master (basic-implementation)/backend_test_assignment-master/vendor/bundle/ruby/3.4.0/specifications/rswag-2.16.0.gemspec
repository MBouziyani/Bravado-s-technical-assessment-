# -*- encoding: utf-8 -*-
# stub: rswag 2.16.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rswag".freeze
  s.version = "2.16.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Richie Morris".freeze, "Greg Myers".freeze, "Jay Danielian".freeze]
  s.date = "2024-11-13"
  s.description = "Generate beautiful API documentation, including a UI to explore and test operations, directly from your rspec integration tests. OpenAPI 2 and 3 supported. More about the OpenAPI initiative here: http://spec.openapis.org/".freeze
  s.email = ["domaindrivendev@gmail.com".freeze]
  s.homepage = "https://github.com/rswag/rswag".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.11".freeze
  s.summary = "OpenAPI (formerly named Swagger) tooling for Rails APIs".freeze

  s.installed_by_version = "3.6.3".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rswag-specs>.freeze, ["= 2.16.0".freeze])
  s.add_runtime_dependency(%q<rswag-api>.freeze, ["= 2.16.0".freeze])
  s.add_runtime_dependency(%q<rswag-ui>.freeze, ["= 2.16.0".freeze])
end
