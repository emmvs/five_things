# Five Things

A Rails app for noticing the small joys in life — log what made you happy, share with friends, and build a streak of good days.

## Documentation

### 🛠️ Development

- [Getting started](docs/getting_started.md) — Prerequisites, install, database, dev server, tests, and linting
- [Deployment](docs/deployment.md)
- [AGENTS.md](AGENTS.md) — Coding standards for AI assistants (security, RuboCop, i18n, testing)
- [CI workflow](.github/workflows/ci.yml) — RuboCop and Brakeman on push/PR to `main`

#### AI agent config

- [`.cursor/rules/rails-standards.mdc`](.cursor/rules/rails-standards.mdc) — Cursor rules (always applied)
- [AGENTS.md](AGENTS.md) — GitHub Copilot / agent instructions

Both enforce the same standards: never commit secrets, RuboCop compliance, DRY, and i18n across `en.yml`, `de.yml`, and `sv.yml`.

## Contributing

If you would like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Contact

- Repository: [emmvs/five_things](https://github.com/emmvs/five_things)
- Emma Rünzel — [emma@ruenzel.de](mailto:emma@ruenzel.de)

Made with ♥️ by emmvs
