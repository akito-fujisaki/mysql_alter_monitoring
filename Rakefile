# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:lint) do |t|
  t.options = %w[--parallel]
end
namespace :lint do
  desc 'Lint fix (Rubocop)'
  task fix: :autocorrect
end

# yard
desc 'Generate and Check code documents'
task :doc do
  require 'yard'
  YARD::CLI::CommandParser.run
  `yard`.lines(chomp: true).last.match(/\d+/)[0].to_i == 100 || exit(1)
end

task default: %i[spec lint doc]
