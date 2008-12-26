Gem::Specification.new do |s|
  s.name = %q{pingfm}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Krunoslav Husak", "Dale Campbell", "Kevin Williams"]
  s.date = %q{2008-09-18}
  s.default_executable = %q{pingfm}
  s.description = %q{Ping.fm (http://ping.fm) is a simple service that makes updating your social networks a snap, and this it's Ruby library.}
  s.email = ["dale@save-state.net", "kevwil@gmail.com"]
  s.executables = ["pingfm"]
  s.extra_rdoc_files = ["History.txt", "bin/pingfm"]
  s.files = [".gitignore", "History.txt", "Manifest.txt", "README", "Rakefile", "bin/pingfm", "lib/pingfm.rb", "lib/pingfm/client.rb", "lib/pingfm/keyloader.rb", "spec/keyloader_spec.rb", "spec/pingfm_spec.rb", "spec/spec_helper.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/manifest.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://pingfm.rubyforge.org/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pingfm}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ping.fm (http://ping.fm) is a simple service that makes updating your social networks a snap, and this it's Ruby library.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
