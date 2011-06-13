$LOAD_PATH.push(File.expand_path("../lib", __FILE__))
require 'pingfm'

Gem::Specification.new do |s|
  s.name = "pingfm"
  s.version = Pingfm::VERSION

  s.authors = ["Dale Campbell", "Kevin Williams", "Krunoslav Husak"]
  s.email = ["oshuma@gmail.com", "kevwil@gmail.com"]
  s.homepage = "http://github.com/Oshuma/pingfm"

  s.rubyforge_project = 'pingfm'

  s.summary = %q{A Ping.fm Ruby library.}
  s.description = %q{Ping.fm (http://ping.fm) is a simple service that makes updating your social networks a snap, and this it's Ruby library.}

  s.add_dependency('bundler')
  s.add_dependency('slop')
  s.add_development_dependency('rspec', '>= 2.6.0')

  s.has_rdoc = true
  s.rdoc_options = ['--inline-source']

  s.require_paths = ["lib"]
  s.files       = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
end
