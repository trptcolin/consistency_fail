# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "consistency_fail/version"

Gem::Specification.new do |s|
  s.name        = "consistency_fail"
  s.version     = ConsistencyFail::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Colin Jones"]
  s.email       = ["colin@8thlight.com"]
  s.homepage    = "http://github.com/trptcolin/consistency_fail"
  s.summary     = %q{A tool to detect missing unique indexes}
  s.description = <<-EOF
With more than one application server, validates_uniqueness_of becomes a lie.
Two app servers -> two requests -> two near-simultaneous uniqueness checks ->
two processes that commit to the database independently, violating this faux
constraint. You'll need a database-level constraint for cases like these.

consistency_fail will find your missing unique indexes, so you can add them and
stop ignoring the C in ACID.
EOF
  s.license = "MIT"

  s.add_development_dependency "activerecord", "~>5.0"
  s.add_development_dependency "sqlite3", "~>1.3"
  s.add_development_dependency "rspec", "~>3.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
