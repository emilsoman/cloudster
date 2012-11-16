# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "cloudster"
  gem.homepage = "http://github.com/emilsoman/cloudster"
  gem.license = "MIT"
  gem.summary = %Q{Cloudster gem - a Ruby interface for provisioning your Amazon Cloud.}
  gem.description = %Q{Cloudster is a Ruby gem that was born to cut the learning curve involved 
    in writing your own CloudFormation templates. If you don't know what a CloudFormation template is, 
    but know about the AWS Cloud offerings, you can still use cloudster to provision your stack. 
    Still in infancy , cloudster can create a very basic stack like a breeze. All kinds of contribution welcome !}
  gem.email = "emil.soman@gmail.com"
  gem.authors = ["Emil Soman"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cloudster #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
