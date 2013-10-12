require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new('spec')
  task :default => :spec
rescue LoadError
end

desc "Create ctags"
task :ctags do
  sh('ctags -R --exclude=.git --exclude=vendor .')
end
