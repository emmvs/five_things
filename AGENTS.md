# Coding Standards

## Security

**NEVER** commit secrets, credentials, or sensitive data to the repository. This includes:

- API keys, tokens, and secrets (e.g. `GOOGLE_OAUTH_CLIENT_SECRET`, `CLOUDINARY_URL`)
- `.env` files (only `.env.sample` with empty values is allowed)
- `config/master.key` or `config/credentials/*.key`
- `cloudinary.yml`
- Database passwords or connection strings with credentials
- Private keys, certificates, or PEM files
- Hardcoded passwords or secrets anywhere in source code

Before every commit:

1. Run `git diff --cached` and review staged files for secrets.
2. Never stage files matching `.env*` (except `.env.sample`), `*.key`, `*.pem`, `credentials.json`, or `cloudinary.yml`.
3. Never hardcode real credentials in seed files, fixtures, tests, or config — use `ENV.fetch("VAR_NAME")` or Rails credentials instead.
4. If a secret is accidentally committed, treat it as compromised — rotate it immediately.

## RuboCop

This project enforces RuboCop (see `.rubocop.yml`). After editing Ruby files:

- Keep methods under 10 lines (`Metrics/MethodLength`) and ABC size under 17 (`Metrics/AbcSize`).
- Keep lines under 120 characters.
- Use early returns (`return ... unless`) to flatten nesting and reduce complexity.
- Extract repeated logic into small, well-named private methods.

## DRY

- Never duplicate the same expression more than once in a method. Extract it into a local variable or helper method.
- Shared controller logic belongs in `ApplicationController` or a concern.
- Shared view logic belongs in helpers or partials.

## i18n / Translations

All user-facing strings **must** use `t()` (Rails I18n), never hardcoded English. This project has three locale files that must be kept in sync:

- `config/locales/en.yml`
- `config/locales/de.yml`
- `config/locales/sv.yml`

When adding a new translation key:

1. Add the key with its English text to `en.yml`.
2. Add the German translation to `de.yml`.
3. Add the Swedish translation to `sv.yml`.
4. Use `%{variable}` syntax for interpolation (e.g. `"User %{email} not found"`).

## Testing

- In specs, reference flash/notice messages via `I18n.t('key')` instead of hardcoded strings. The locale files are the single source of truth.
