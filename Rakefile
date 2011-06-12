require 'bundler'
require 'rdoc/task'
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

namespace :docs do
  RDoc::Task.new do |rd|
    rd.title = "Pingfm API Docs"
    rd.main = "README.rdoc"
    rd.rdoc_dir = "#{File.dirname(__FILE__)}/doc/api"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rd.options << "--all"
  end
end
