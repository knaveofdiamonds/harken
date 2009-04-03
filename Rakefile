require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Run unit tests'
task :default => :test

desc 'Run unit tests'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/test_*.rb'
  t.verbose = true
end

desc 'Generate project documentation'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Harken'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/message.rb')
end


desc 'Compile treetop grammar to ruby'
task :compile do
  `tt src/message.treetop -o lib/message.rb`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "harken"
    s.summary = "DSL for writing XMPP bots"
    s.email = "roland.swingler@gmail.com"
    s.homepage = "http://harken.rubyforge.org/"
    s.description = "Provides a simple DSL for responding to messages in an XMPP chat room."
    s.authors = ["Roland Swingler"]
    s.files =  FileList["[A-Z]*", "{src,lib,test}/**/*"]
    s.add_dependency 'treetop'
    s.add_dependency 'xmpp4r'
  end
rescue LoadError
  warn "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
