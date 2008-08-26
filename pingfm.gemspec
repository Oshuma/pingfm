Gem::Specification.new do |s|
  s.name = %q{pingfm}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Krunoslav Husak, Dale Campbell, Kevin Williams"]
  s.date = %q{2008-08-25}
  s.default_executable = %q{pingfm}
  s.description = %q{Ping fm (http://ping.fm) is a simple service that makes updating your social networks a snap, and this it's Ruby library.}
  s.email = %q{kevwil@gmail.com}
  s.executables = ["pingfm"]
  s.extra_rdoc_files = ["History.txt", "bin/pingfm"]
  s.files = ["History.txt", "Manifest.txt", "README", "Rakefile", "bin/pingfm", "lib/client.rb", "lib/pingfm.rb", "pingfm.gemspec", "spec/pingfm_spec.rb", "spec/spec_helper.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/manifest.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "test/test_pingfm.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/kevwil/pingfm/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pingfm}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ping fm (http://ping.fm) is a simple service that makes updating your social networks a snap, and this it's Ruby library.}
  s.test_files = ["test/test_pingfm.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
  end
end
