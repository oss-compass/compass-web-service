# Compass Web Service

This project is a backend repository for [OSS-Compass](https://oss-compass.org/), based on Rails 7 and Ruby 3.

## Running this app

You need to do few small steps to run the app

### Clone the repo

```sh
git clone https://github.com/oss-compass/compass-web-service
cd compass-web-service
```

### Copy example file

```sh
cp .env.example .env.local
```

Environment variables defined here(`.env`), feel free to change or add variables as needed.
This file is ignored from git (Check `.gitignore`) so it will never be commit.

If you use different values for environment variables in other envs, e.g. **test**, you need to copy one more: `.env.test.local`

**Note** `.env.test` is used by github workflows.

### Setup the project

create databases

```sh
rails db:setup
```

database migration

```sh
rails db:migrate
```

### Start the project

```sh
rails s
```

#### Cron tasks

Start a scheduled task service to regularly update project reports as well as summary reports.

```sh
bundle exec crono -e development
```

#### Start sneaker workers

Start an asynchronous task queue for use in checking repository validity and handling exceptional requests, etc.

```sh
bundle exec rake rabbitmq:start
```
