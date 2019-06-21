# frozen_string_literal: true

module MigrationSignature
  class MigrationFile
    MIGRATION_SIG_PREFIX = '# migration_signature: '

    def self.resolve_full_name(path_or_version)
      path =
        if path_or_version =~ /^\d+$/
          Dir["#{MigrationSignature.config.migration_dir}/#{path_or_version}*"]
            .first
        else
          File.expand_path(path_or_version)
        end

      return path if path && File.exist?(path)

      bad_basename = path ? path.split('/').last : path_or_version
      raise("Could not find migration #{bad_basename}")
    end

    def initialize(path_or_version)
      @path = self.class.resolve_full_name(path_or_version)
    end

    def ignore?
      MigrationSignature.config.ignore?(@path)
    end

    def update_signature!
      new_lines = lines.dup
      unless signature?
        new_lines.unshift("\n")
        # add blank line between magic comments and content
        if !new_lines[1].empty? && !new_lines[2].start_with?('#')
          new_lines.unshift("\n")
        end
      end

      new_lines[signature_line_number || 0] = new_source_signature_line
      write_to_file(new_lines)
    end

    def validate_signature!
      return true if valid_signature?

      raise MigrationSignature::InvalidSignatureError,
            'Missing or invalid migration signature in migration: ' \
            "#{basename}. Please re-run your migration to receive an " \
            'updated signature.'
    end

    def basename
      File.basename(path)
    end

    private

    attr_reader :path

    def valid_signature?
      return false unless signature?

      comment_signature = lines[signature_line_number]
                          .sub(MIGRATION_SIG_PREFIX, '')
                          .strip
      comment_signature == source_signature
    end

    def new_source_signature_line
      "#{MIGRATION_SIG_PREFIX}#{source_signature}\n"
    end

    def source_signature
      Digest::MD5.hexdigest(Parser::CurrentRuby.parse(lines.join).inspect)
    end

    def signature?
      signature_line_number && signature_line_number > -1
    end

    def signature_line_number
      lines.index { |l| l.start_with?(MIGRATION_SIG_PREFIX) }
    end

    def lines
      @lines ||= File.read(path).lines
    end

    def write_to_file(new_lines)
      File.write(path, new_lines.join)
      remove_instance_variable(:@lines) if defined?(@lines)
      true
    end
  end
end
