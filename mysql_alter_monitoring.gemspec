# frozen_string_literal: true

require_relative 'lib/mysql_alter_monitoring/version'

Gem::Specification.new do |spec|
  spec.name = 'mysql_alter_monitoring'
  spec.version = MysqlAlterMonitoring::VERSION
  spec.authors = ['Akito Fujisaki']
  spec.email = ['52433677+akito-fujisaki@users.noreply.github.com']

  spec.summary = 'MySQL ALTER TABLE monitoring tool.'
  spec.description = 'Monitoring ALTER TABLE Progress for InnoDB Tables Using Performance Schema.'
  spec.homepage = 'https://github.com/akito-fujisaki/mysql_alter_monitoring'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir['{exe,lib}/**/*', '*.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mysql2', '>= 0.5.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
