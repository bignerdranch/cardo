# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cardo/version"

Gem::Specification.new do |s|
  s.name        = "cardo"
  s.version     = Cardo::VERSION
  s.authors     = ["Andy Lindeman"]
  s.email       = ["andy@highgroove.com"]
  s.homepage    = "http://github.com/highgroove/cardo"
  s.summary     = %q{DSL for creating recurring Pivotal Tracker stories}
  s.description = %q{At Highgroove, we use Pivotal Tracker with customers, but also for tracking internal work. Things like code reviews, pairing sessions, and blog post duty need to be created each week. Cardo is how we automate it!}

  s.rubyforge_project = "cardo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "peaty", ">=0.5.0"

  s.add_development_dependency "rspec", "~>2.6.0"
end
