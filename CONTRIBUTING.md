## Contributing to Compass Web Service

Thank you for considering contributing to Compass Web Service! We welcome contributions of all kinds, from bug fixes to new features.

### Guidelines

- Please follow the [code of conduct](CODE_OF_CONDUCT.md) when interacting with the project community.
- Ensure that your code adheres to the project's style guidelines.
- Write clear and concise commit messages.
- Provide tests for your changes.
- Submit your changes as pull requests.

### Development Setup

1. Clone the repository:

```
git clone https://github.com/open-metrics-code/compass-web-service
cd compass-web-service
```

2. Copy the example environment file:

```
cp .env.example .env.local
```

3. Setup the project:

```
rails db:setup
rails db:migrate
```

4. Start the project:

```
rails s
```

### Running Cron Tasks

To start a scheduled task service that regularly updates project reports and summary reports, run the following command:

```
bundle exec crono -e development
```

### Running Sneaker Workers

To start an asynchronous task queue for checking repository validity, handling exceptional requests, etc., run the following command:

```
bundle exec rake rabbitmq:start
```

### Pull Requests

When submitting a pull request, please include the following information:

- A brief description of the changes you have made.
- A reference to any relevant issues or discussions.
- Any tests or benchmarks that you have performed.

### Code Reviews

All pull requests will be reviewed by at least one other contributor before being merged. Please be patient during the review process.

### Additional Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide)
- [Git Best Practices](https://git-scm.com/book/en/v2/Best-Practices)
