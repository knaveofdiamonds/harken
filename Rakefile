require 'rake'
require 'rake/testtask'

desc 'Run unit tests'
task :default => :test

desc 'Run unit tests'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/test_*.rb'
  t.verbose = true
end
