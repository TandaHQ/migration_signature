# frozen_string_literal: true

module MigrationSignature
  class Railtie < Rails::Railtie
    initializer 'migration_signatures.prepend migrator' do
      ActiveRecord::Migrator.prepend(MigrationSignature::MigratorEnhancement)
    end
  end

  module MigratorEnhancement
    def run
      res = super
      return res unless @direction == :up

      MigrationSignature.build_file(@target_version.to_s)

      puts('Migration signature successfully built')
      res
    end

    def migrate
      runnable = super

      return runnable if @direction && @direction != :up

      runnable.each do |migration|
        MigrationSignature.build_file(migration.filename)
      end

      puts('Migration signatures successfully built')
      runnable
    end
  end
end
