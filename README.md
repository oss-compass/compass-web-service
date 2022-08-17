# Compass Web Service

**This app is using Rails 7, Ruby 3, Vite, Vue 3 and typescript**

**使用CHAOSS工具集构建的开源度量指数 2.0 （Working in process)**

### Backend

- 1- [Mariadb](https://mariadb.org/)
- 2- [RSpec](https://github.com/rspec/rspec-metagem)
- 3- [Factory Bot Rails](https://github.com/thoughtbot/factory_bot_rails)
- 4- [Faker](https://github.com/faker-ruby/faker)
- 5- [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner)
- 6- [SimpleCov](https://github.com/simplecov-ruby/simplecov)
- 7. Rubocop(Check the [**Healthy app/Backend**](#healthy-app) part)
- 8- [Annotate](https://github.com/ctran/annotate_models)
- 9- [Pry](https://github.com/pry/pry)
- 10- [Pagy](https://github.com/ddnexus/pagy)
- 11- [HasScope](https://github.com/heartcombo/has_scope)
- 12- [JSON:API serializer](https://github.com/jsonapi-serializer/jsonapi-serializer) A fast JSON:API serializer for Ruby Objects
  - [jsonapi.rb](https://github.com/stas/jsonapi.rb) which provides some features for `jsonapi-serializer`
  - [jsonapi-rspec](https://github.com/jsonapi-rb/jsonapi-rspec) which provides some beautiful RSpec matchers for JSON API
- 13- [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html)
- 14- [Redis](https://redis.io/)
- 15- [Sidekiq](https://github.com/mperham/sidekiq)
- 16- [dotenv](https://github.com/bkeepers/dotenv)

### Frontend

- 17- [Vite](https://github.com/ElMassimo/vite_ruby) Removing importmaps and all frontend libraries and Use Vite instead
- 18- Code quality and format (Check **Healthy app/Frontend** part)
- 19- [Vue.js](https://vuejs.org/) Vue.js version 3
- 20- Enabling auth process(and make the app ready) which needed more packages
  - [axios](https://www.npmjs.com/package/axios)
  - [pinia](https://pinia.vuejs.org/introduction.html) The official state management library for Vue. will be used instead of **Vuex**
  - [vue-query](https://www.npmjs.com/package/vue-query)
  - [@babel/types](https://babeljs.io/docs/en/babel-types)
  - We start using [TypeScript](https://www.typescriptlang.org/) and [Vue3 compistion API](https://vuejs.org/guide/extras/composition-api-faq.html) here

### Healthy app

#### Frontend

- 21- Code quality and format
  - [ESlint](https://eslint.org/)
  - [Eslint plugin vue](https://eslint.vuejs.org/rules/)
  - [Prettier](https://prettier.io/)
  - [Husky](https://typicode.github.io/husky/#/)
  - [lint-staged](https://github.com/okonet/lint-staged)

#### Backend

- 21- [RuboCop](https://github.com/rubocop/rubocop) Code quality and format.

- 22- [Brakeman](https://github.com/presidentbeef/brakeman) Checking Ruby on Rails applications for security vulnerabilities. you can check `config/brakeman.ignore` to see ignore errors
- 23- [bundler-audit](https://github.com/rubysec/bundler-audit) Patch-level verification for bundler
- 24- [Fasterer](https://github.com/DamirSvrtan/fasterer) Make Rubies code faster by suggestion some speed improvements. check `.fasterer.yml` to enable/disable suggestions
- 25- [License Finder](https://github.com/pivotal/LicenseFinder) Check the licenses of the gems and packages. you can update `doc/dependency_decisions.yml` to manage licenses

#### Common

- 24- [overcommit](https://github.com/sds/overcommit) to manage and configure Git hooks by managing all healthy app tools. you can check `.overcommit.yml` to enable or disable tools
- 25- Enabling github action to run `overcommit` after push and pull requests in github. Check `.github/workflows/lint.yml` to see the github configs

## Auth

- 26- [Devise](https://github.com/heartcombo/devise) and [Devise::JWT](https://github.com/waiting-for-dev/devise-jwt) JWT authentication solution

Predefined auth routes:

### `/signup`

**Request**:

```
curl -XPOST -H "Content-Type: application/json" -d '{ "user": { "email": "test@example.com", "password": "12345678", "password_confirmation": "12345678" } }' http://localhost:3000/signup
```

**Response**: Returns the details of the created user

```
{"data":{"id":"4","type":"user","attributes":{"email":"test@example.com","sign_in_count":1,"created_at":"2022-04-18T17:49:06.798Z"}}}
```

### `/login`

**Request**:

```bash
curl -XPOST -i -H "Content-Type: application/json" -d '{ "user": { "email": "test@example.com", "password": "12345678" } }' http://localhost:3000/login
```

**Response**: includes `Authorization` in header and details of the loggedin user

```bash
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 0
X-Content-Type-Options: nosniff
X-Download-Options: noopen
....
Content-Type: application/vnd.api+json; charset=utf-8
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjUwMzA0MjU3LCJleHAiOjE2NTAzOTA2NTcsImp0aSI6IjM4ZmI4ZGIyLWVlMjgtNDg2Yy05YjE5LTA2NWVmYmQ0ZGE4MCJ9.p8766vPrhiGpPyV2FdShw1ljBx2Os3D1oE_rPjjAYrY
...

{"data":{"id":"4","type":"user","attributes":{"email":"test@example.com","sign_in_count":2,"created_at":"2022-04-18T17:49:06.798Z"}}}
```

### `/logout`

**Request**: includes `Authorization` and its JWT token in the header of `DELETE` request

```bash
curl -XDELETE -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjUwMzA0MjU3LCJleHAiOjE2NTAzOTA2NTcsImp0aSI6IjM4ZmI4ZGIyLWVlMjgtNDg2Yy05YjE5LTA2NWVmYmQ0ZGE4MCJ9.p8766vPrhiGpPyV2FdShw1ljBx2Os3D1oE_rPjjAYrY" -H "Content-Type: application/json" http://localhost:3000/logout
```

**Response**: nothing

**Note** We are using JWT to authentication, it means you can use this Rails base app as a **vanilla rails app** (Backend and frontend together), or as a **Rails API app**. both you can use.

## Running this app

You need to do few small steps to run the app

### Clone the repo

```sh
git clone https://gitee.com/oschina/compass-web-service
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

### start the project

- rails server

  ```sh
  rails s
  ```

- frontend app

  ```sh
  yarn dev
  ```

## TODO

- [ ] 集成 Grimoirelab
- [ ] Dockerize
