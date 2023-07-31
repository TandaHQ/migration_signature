# frozen_string_literal: true

module MigrationSignature
  class Config
    DEFAULTS = {
      'ignore' => [],
      'rails_dir' => Dir.pwd,
      'migration_dir' => 'db/migrate'
    }.freeze

    CONFIG_FILE_PATH = "#{Dir.pwd}/.migration_signature.yml"

    def self.load
      return new(DEFAULTS) unless File.exist?(CONFIG_FILE_PATH)

      require 'yaml'
      hash = if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
        YAML.safe_load(File.read(CONFIG_FILE_PATH), permitted_classes: [Regexp])
      else
        YAML.safe_load(File.read(CONFIG_FILE_PATH), [Regexp])
      end || {}

      new(DEFAULTS.merge(hash))
    end

    def initialize(opts = DEFAULTS)
      @opts = opts
    end

    def all_runnable_files
      @all_runnable_files ||= begin
        require 'pathname'

        Dir["#{migration_dir}/*"].sort.reject do |f|
          ignore?(f)
        end
      end
    end

    def migration_dir
      "#{@opts['rails_dir']}/#{@opts['migration_dir']}"
    end

    def ignore?(file)
      rails_root_file =
        Pathname.new(file).relative_path_from(@opts['rails_dir']).to_s

      return true if string_ignores.include?(file)
      return true if string_ignores.include?(rails_root_file)
      return true if regexp_ignores.any? { |ignore| ignore =~ file }
      return true if regexp_ignores.any? { |ignore| ignore =~ rails_root_file }

      false
    end

    private

    def regexp_ignores
      @regexp_ignores ||= @opts['ignore'].find_all { |i| i.is_a?(Regexp) }
    end

    def string_ignores
      @string_ignores ||= @opts['ignore'].reject { |i| i.is_a?(Regexp) }
    end
  end
end
