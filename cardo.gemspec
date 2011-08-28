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
  s.add_dependency "chronic", ">=0.6.2"

  s.add_development_dependency "rake", "0.9.2"
  s.add_development_dependency "rspec", "~>2.6.0"
  s.add_development_dependency "vcr", "~>1.10.3"
  s.add_development_dependency "webmock", "~>1.6.4"
  s.add_development_dependency "timecop", "~>0.3.5"
  unless ENV["CI"]
    s.add_development_dependency "ruby-debug19"
  end
  s.add_development_dependency "activesupport", "~>3.0.0"
end
