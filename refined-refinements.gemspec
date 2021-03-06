#!/usr/bin/env gem build
# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'refined-refinements'
  s.version     = '0.0.2.4'
  s.authors     = ['James C Russell']
  s.email       = 'james@101ideas.cz'
  s.homepage    = 'http://github.com/botanicus/refined-refinements'
  s.summary     = ''
  s.description = "#{s.summary}."
  s.license     = 'MIT'
  s.files       = Dir.glob('{lib}/**/*.rb') + ['README.md']
end
