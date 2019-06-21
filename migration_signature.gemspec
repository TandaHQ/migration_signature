# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'migration_signature/version'

Gem::Specification.new do |spec|
  spec.name          = 'migration_signature'
  spec.version       = MigrationSignature::VERSION
  spec.authors       = ['Dave Allie']
  spec.email         = ['dave@tanda.co']

  spec.summary       = 'Generate signatures for migration files when they ' \
                       'are run and check them in CI.'
  spec.description   = 'A small Rails utility to ensure all migration files ' \
                       'have been tested before they are committed and run ' \
                       'in production.'
  spec.homepage      = 'https://github.com/TandaHQ/migration_signature'
  spec.license       = 'MIT'

  spec.files         = Dir['exe/*'] + Dir['lib/**/*'] +
                       %w[Gemfile migration_signature.gemspec]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'parser', '>= 2'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
