# frozen_string_literal: true

require 'parser/current'
require 'digest/md5'
require_relative './migration_signature/config'
require_relative './migration_signature/migration_file'
require_relative './migration_signature/railtie' if defined?(Rails)

module MigrationSignature
  class InvalidSignatureError < StandardError; end

  def self.config
    @config ||= MigrationSignature::Config.load
  end

  def self.check_all
    config.all_runnable_files.each do |path|
      MigrationSignature::MigrationFile.new(path).validate_signature!
    end

    true
  end

  def self.build_all
    config.all_runnable_files.each do |path|
      MigrationSignature::MigrationFile.new(path).update_signature!
    end
  end

  def self.build_file(file)
    mf = MigrationSignature::MigrationFile.new(file)

    if mf.ignore?
      warn "Tried to build signature for #{mf.basename}, but it is ignored."
      return
    end

    mf.update_signature!
  end
end
