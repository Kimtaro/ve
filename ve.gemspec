# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 've'
  s.version     = '0.0.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Kim Ahlström']
  s.email       = ['kim.ahlstrom@gmail.com']
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/kimtaro/ve'
  s.summary     = 'Ve is a linguistic framework for programmers'
  s.description = 'Ve is a linguistic framework for programmers.'

  # The list of files to be contained in the gem
  s.files         = `git ls-files`.split("\n")
  # s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  # s.extensions    = `git ls-files ext/extconf.rb`.split("\n")

  s.require_paths = ['lib']

  # For C extensions
  # s.extensions = 'ext/extconf.rb'
end
