# Close Friends newsletter

A minimal newsletter built into five_things: public signup with email confirmation, manual approval, plain-text issues (draft → publish → send), and unsubscribe links. You write each issue in the language you want subscribers to read it in; title and body are delivered as-is. Only surrounding UI (signup, dashboard, confirmation emails, unsubscribe link, etc.) is translated via the app locales.

## Configuration

Add to `.env` (see `.env.sample`):

```bash
CLOSE_FRIENDS_PUBLISHER_USER_IDS=  # comma-separated User IDs allowed to publish
```

Restart the app after changing this value.

## Subscriber flow

1. Share the link: `/close_friends`
2. They enter their name and email (validated like app user signups) and receive a confirmation message.
3. They click the link in that email (`confirmed_at` is set).
4. You approve or reject them from the publisher dashboard.

Only **approved** subscribers receive issues. Rejecting removes the pending record; that email can sign up again.

## Publisher flow

Log in as a user listed in `CLOSE_FRIENDS_PUBLISHER_USER_IDS`, then open:

**`/close_friends/dashboard`** — subscriber count, approval queue, issue list

| Action | URL |
|--------|-----|
| Signup | `/close_friends` |
| Publisher dashboard | `/close_friends/dashboard` |
| New draft | `/close_friends/issues/new` |
| Edit draft / published issue | `/close_friends/issues/:id/edit` |
| Public page (after publish) | `/close_friends/issues/:id` |

1. **Draft** — paste title and body (plain text).
2. **Publish** — issue is visible on the web; you can still edit.
3. **Send** — one email per approved subscriber via Action Mailer (same SMTP as the rest of the app). Each email includes an unsubscribe link.

An issue cannot be sent twice (`sent_at` is set on send).

## Security notes

- Draft issues are not publicly visible.
- Non-publishers get 404 on publisher routes (not 403).
- Confirm and unsubscribe links use signed, expiring tokens (no token columns in the database).
- Signup requires valid name and email; new subscribers still need email confirmation and publisher approval before receiving issues.

## Code map

| Area | Location |
|------|----------|
| Routes | `config/routes.rb` (`namespace :close_friends`) |
| Models | `app/models/close_friends_issue.rb`, `close_friends_subscriber.rb` |
| Controllers | `app/controllers/close_friends/` |
| Publisher auth | `app/controllers/concerns/close_friends/publisher_authorization.rb` |
| Mailer | `app/mailers/close_friends_mailer.rb` |
| Specs | `spec/requests/close_friends_spec.rb` |
