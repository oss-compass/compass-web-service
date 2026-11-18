# Shortened-label lifecycle regression tests

Run through the application's normal Rails test environment:

```sh
bin/rails test test/models/shortened_label_test.rb
```

The same cases can run with a focused dependency set and a disposable MariaDB
database. This executes the actual ApplicationRecord and ShortenedLabel classes,
Active Record callbacks/queries, Nanoid and the Rails memory cache. It does not
boot the complete application or exercise production Riak caching.

Create a disposable MariaDB instance with database `compass_short_label_test`,
then use Ruby 3.3.6 and the model dependency versions from the application lockfile:

```sh
BUNDLE_GEMFILE=test/gemfiles/shortened_label.gemfile bundle install
COMPASS_SHORT_LABEL_NATIVE=1 \
COMPASS_SHORT_LABEL_DATABASE=compass_short_label_test \
COMPASS_SHORT_LABEL_USER=root \
COMPASS_SHORT_LABEL_PASSWORD=your_disposable_database_password \
BUNDLE_GEMFILE=test/gemfiles/shortened_label.gemfile \
bundle exec ruby -Itest test/models/shortened_label_test.rb
```

The focused runner recreates only `shortened_labels` and its indexes in that
explicitly named test database. Use a disposable server; it is not an application
database migration. The tests cover persisted validations/saves, failed and custom
validation contexts, label updates, public convert/revert behavior, cache expiry,
new repository/community codes, uniqueness and duplication of persisted records.
