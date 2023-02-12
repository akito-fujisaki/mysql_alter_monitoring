# MysqlAlterMonitoring

Monitoring ALTER TABLE Progress for InnoDB Tables Using Performance Schema.

See: https://dev.mysql.com/doc/refman/8.0/en/monitor-alter-table-performance-schema.html

## Installation

Add this line to your application's Gemfile:

```
gem 'mysql_alter_monitoring'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install mysql_alter_monitoring
```

## Usage

TODO

## Development

To develop on docker, build first.

```
$ bin/docker-compose build
```

Enter docker container and run rake task etc.

```
$ bin/docker-compose run --rm gem bash
```

### rspec

```
# Run all specs
$ bin/rake spec

# Run specs individually
$ bin/rspec spec/mysql_alter_monitoring/monitor_spec.rb
```

### rubocop

```
# Run lint
$ bin/rake rubocop

# Run rubocop autocorrect
$ bin/rake lint:fix
```

### yard

```
# Generate and Check code documents
# Output to doc/index.html
$ bin/rake doc
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akito-fujisaki/mysql_alter_monitoring.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/akito-fujisaki/mysql_alter_monitoring/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MysqlAlterMonitoring project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/akito-fujisaki/mysql_alter_monitoring/blob/main/CODE_OF_CONDUCT.md).
