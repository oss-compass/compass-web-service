# Dataset row merge/difference regression tests

Run through the application's normal Rails test environment:

```sh
bin/rails test test/models/lab_dataset_rows_test.rb
```

For a focused run, create a disposable MariaDB instance with database
`compass_dataset_rows_test`, use Ruby 3.3.6 and install the pinned model/GraphQL
dependencies from the application lockfile:

```sh
BUNDLE_GEMFILE=test/gemfiles/lab_dataset_rows.gemfile bundle install
COMPASS_DATASET_ROWS_NATIVE=1 \
COMPASS_DATASET_DATABASE=compass_dataset_rows_test \
COMPASS_DATASET_USER=root \
COMPASS_DATASET_PASSWORD=your_disposable_database_password \
BUNDLE_GEMFILE=test/gemfiles/lab_dataset_rows.gemfile \
bundle exec ruby -Itest test/models/lab_dataset_rows_test.rb
```

This uses the actual mutation class and row input type through GraphQL input
coercion, the actual label normalizer and the real LabDataset item reader.
The native setup uses Active Record, MariaDB and the Rails memory cache, and
recreates only `lab_datasets`, `shortened_labels` and their indexes in its
explicitly named disposable database. Normal Rails runs do not execute that setup.

Coverage is row merging/difference, batch validation and reading merged rows.
The full mutation resolver's permission/fork flow, external analysis dispatch,
HTTP requests and the complete application suite are outside this focused run.
