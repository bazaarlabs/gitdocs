# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'gitdocs/version'

Gem::Specification.new do |s|
  s.name        = 'gitdocs'
  s.version     = Gitdocs::VERSION
  s.authors     = ['Josh Hull', 'Nathan Esquenazi']
  s.email       = ['joshbuddy@gmail.com', 'nesquena@gmail.com']
  s.homepage    = 'https://github.com/nesquena/gitdocs'

  s.summary     = 'Open-source Dropbox using Ruby and Git.'
  s.description = 'Open-source Dropbox using Ruby and Git.'
  s.license     = 'MIT'

  s.rubyforge_project = 'gitdocs'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9'

  s.add_dependency 'celluloid',       '~> 0.16.0'
  s.add_dependency 'reel-rack',       '~> 0.2.2'
  s.add_dependency 'listen',          '~> 3.0.5'
  # HACK: reel is still waiting for its dependencies on
  # HTTP::Response::STATUS_CODES to be fixed, so for the moment it will only
  # work with a <1.0.0 version of HTTP. This can be removed and the gems
  # updated once reel 0.6.0 is released.
  # https://github.com/celluloid/reel/issues/213
  s.add_dependency 'http',            '= 0.9.8'

  s.add_dependency 'sinatra',         '~> 1.4.5'
  s.add_dependency 'redcarpet',       '~> 3.3.0'
  s.add_dependency 'thor',            '~> 0.14.6'
  s.add_dependency 'coderay',         '~> 1.1.0'
  s.add_dependency 'dante',           '~> 0.2.0'
  s.add_dependency 'growl',           '~> 1.0.3'
  s.add_dependency 'haml',            '~> 4.0.5'
  s.add_dependency 'sqlite3',         '~> 1.3.4'
  s.add_dependency 'activerecord',    '~> 4.2.0'
  s.add_dependency 'grit',            '~> 2.5.0'
  s.add_dependency 'mimetype-fu',     '~> 0.1.2'
  s.add_dependency 'launchy',         '~> 2.4.2'
  s.add_dependency 'rugged',          '~> 0.23.0'
  s.add_dependency 'table_print',     '~> 1.5.1'
  s.add_dependency 'notiffany',       '~> 0.0.8'

  s.add_development_dependency 'minitest',               '~> 5.8.0'
  s.add_development_dependency 'capybara_minitest_spec', '~> 1.0.2'
  s.add_development_dependency 'shell_tools',            '~> 0.1.0'
  s.add_development_dependency 'poltergeist',            '~> 1.7.0'
  s.add_development_dependency 'rake',                   '~> 10.4.2'
  s.add_development_dependency 'mocha',                  '~> 1.1.0'
  s.add_development_dependency 'aruba',                  '~> 0.6.1'
  s.add_development_dependency 'rubocop',                '~> 0.34.2'
  s.add_development_dependency 'haml-lint',              '~> 0.13.0'
  s.add_development_dependency 'jslint_on_rails',        '~> 1.1.1'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'shotgun',                '~> 0.9.1'
end
