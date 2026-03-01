# Coding Standards

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
