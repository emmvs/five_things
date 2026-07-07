# Getting started

These instructions get the project running on your local machine.

## Prerequisites

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) 3.4.4
- [Rails](https://guides.rubyonrails.org/) 8.0.3
- PostgreSQL

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/emmvs/five_things.git
   cd five_things
   ```

2. Install gems:

   ```bash
   bundle install
   ```

3. Install and start PostgreSQL:

   ```bash
   brew install postgresql
   brew services start postgresql
   ```

## Database

```bash
rails db:create
rails db:migrate
rails db:seed
```

## Development server

**Option 1: Foreman (recommended)**

Starts Rails and ngrok together:

```bash
bin/dev
```

- Rails: `http://localhost:3000`
- ngrok URL appears in the logs (for mobile testing)

**Option 2: Manual (recommended for `binding.pry`)**

Terminal 1:

```bash
rails s
```

Terminal 2:

```bash
ngrok http 3000
```

Use the ngrok forwarding URL on your phone. URLs may end in `.app`, `.dev`, or `.io` depending on your ngrok account.

## Testing

```bash
rspec                              # full suite
rspec spec/requests/users_spec.rb  # single file
```

## Linting & security

```bash
bundle exec rubocop
bundle exec brakeman -q -w2
```

CI runs RuboCop and Brakeman on every push and PR to `main` (see `.github/workflows/ci.yml`).

## Environment variables

Secrets must never be committed. Use `.env` locally (git-ignored) and add new keys to `.env.sample` with empty values. Access them in code via `ENV.fetch("VAR_NAME")` or Rails credentials.

## Services

- **Poetry service** — fetches a random poem for the dashboard quote.
