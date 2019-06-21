# Migration Signature

Sign your Rails migrations with file content, so no untested migrations make
it out of CI. 

## About

Have you ever had a migration like the following, which you've tested, run,
and are sure behaves normally, which is committed on your branch, and ready to
go to production.

```ruby
class MyMigration < ActiveRecord::Migration[5.2]
  def change
    do_something_safe
  end
end
```

Then, right before you merge your branch you decide to swap out the method in
your migration for another method, forgetting to rollback and run the migration
again.

```ruby
class MyMigration < ActiveRecord::Migration[5.2]
  def change
    do_something_dangerous
  end
end
```

Because the migration is already 'up' and changes to `structure.sql` or 
`schema.rb` are committed, it's unlikely your test environment will ever 
re-execute the code in the `change` method. So the first time your
`do_something_dangerous` method gets executed will be when this migration is
run in production.

To get around this issue, Tanda introduced migration 'signatures'. A hash of
the migration's AST stored as a comment in the migration file itself.

When the migration file is initially created and run, a signature gets added
automatically to the top of the file:

```ruby
# migration_signature: 22e8a816f8db8d51cec29fca5e8c08f7

class MyMigration < ActiveRecord::Migration[5.2]
  def change
    do_something_safe
  end
end
```

If the contents of the migration change, the signature will become invalid,
meaning we can pick up un-run migrations in CI before sending them to 
production.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'migration_signature', group: :development
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install migration_signature
```

To build signatures for all existing migrations, run the following:

```bash
bundle exec migration_signature buildall
```

## Usage

Migration signatures will automatically be prepended to migration files when 
the up migration is run. To check the generated signatures match the migration
file contents, add the following to your CI pipeline or pre-commit hook:

```bash
bundle exec migration_signature check
```

This command will either exit successfully or exit with code 1 and an error 
message.

```bash
> bundle exec migration_signature check

Missing or invalid migration signature in migration: 20190621040327_my_migration.rb. Please re-run your migration to receive an updated signature.
```

## Configuration

You may wish to ignore specific migration files based on age or other factors.
You can configure which migration files get ignored by creating a
`.migration_signature.yml` file in the root of your repo (or from whatever) the
working directory is when the gem is invoked.

```yaml
# .migration_signature.yml
ignore:
  - '/full/path/to/repo/db/migrate/20190621040327_my_migration_1.rb'
  - 'db/migrate/20190621040328_my_migration_2.rb'
  - !ruby/regexp /db\/migrate\/201[2-4].*$/ # ignore migrations from 2012 - 2014
```
