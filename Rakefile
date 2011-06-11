require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks  

task :default => :spec

desc 'Start a console loaded with the library'
task :console do
  sh "irb -I ./lib -r 'pingfm'"
end

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color']
end
