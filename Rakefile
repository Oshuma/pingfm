require 'spec/rake/spectask'

task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--color']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Start a console loaded with the library'
task :console do
  sh "irb -I ./lib -r 'pingfm'"
end


#
# Doc tasks
#
LIB_ROOT = File.join(File.dirname(__FILE__), 'lib')
DOC_ROOT = File.join(File.dirname(__FILE__), 'doc', 'api')

desc 'Generate API docs'
task :doc => [ 'doc:api' ]

namespace :doc do

  task :setup_rdoc do
    @files = Dir[
      "README.rdoc",
      "lib/**/*.rb",
    ].collect { |f| f.gsub(/#{LIB_ROOT}/, '.') }

    @options = [
      "--all",
      "--inline-source",
      "--line-numbers",
      "--main README.rdoc",
      "--op #{DOC_ROOT}",
      "--title 'Ping.fm Ruby API'",
    ]
  end

  task :api => [ :setup_rdoc ] do
    sh "rdoc #{@options.join(' ')} #{@files.join(' ')}"
  end

  desc 'Remove API docs'
  task :remove do
    sh "rm -rf #{DOC_ROOT}" if File.exists?(DOC_ROOT)
  end

  desc 'Remove and rebuild API docs'
  task :rebuild => [ 'doc:remove', 'doc:api' ]

end
