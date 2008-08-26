# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'pingfm'

task :default => 'spec:run'

PROJ.name = 'pingfm'
PROJ.authors = 'Krunoslav Husak, Dale Campbell, Kevin Williams'
PROJ.email = 'kevwil@gmail.com'
PROJ.url = 'http://github.com/kevwil/pingfm/'
PROJ.version = ENV['VERSION'] || Pingfm.version
PROJ.rubyforge.name = 'pingfm'
PROJ.readme_file = 'README'
PROJ.gem.dependencies << 'libxml-ruby'

PROJ.spec.opts << '--color'

namespace :gem do
  desc 'create a gemspec file to support github gems'
  task :gemspec => 'gem:prereqs' do
    File.open("#{PROJ.name}.gemspec", 'w+') do |f|
      f.write PROJ.gem._spec.to_ruby
    end
  end
end

# EOF
