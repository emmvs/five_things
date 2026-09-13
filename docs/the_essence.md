# The Essence newsletter signup

Public signup for The Essence newsletter: a conversational page at `/the_essence/sign_up`, email invitation, accept page, and unsubscribe links.

## QR code

Encode this URL in your QR code:

```
https://www.my5things.com/the_essence/sign_up
```

## Subscriber flow

1. Visitor opens `/the_essence/sign_up` and enters their name and email one question at a time.
2. They receive an invitation email.
3. The email link opens the final signup page on the site.
4. Pressing **We accept ✨** subscribes them and shows "Welcome to the essence! ✨".

Accepting and unsubscribing happen when the visitor presses the button on the page, not when the email link is fetched. That prevents mail scanners and link-prefetchers from accepting or unsubscribing on a reader's behalf.

## Routes

| Action | URL |
|--------|-----|
| Signup | `/the_essence/sign_up` |
| Accept (from email) | `/the_essence/confirm?token=...` |
| Unsubscribe | `/the_essence/unsubscribe?token=...` |

## Code map

| Area | Location |
|------|----------|
| Routes | `config/routes.rb` |
| Model | `app/models/essence_subscriber.rb` |
| Controller | `app/controllers/essence/subscribers_controller.rb` |
| Signup UI | `app/javascript/controllers/essence_signup_controller.js` |
| Mailer | `app/mailers/essence_mailer.rb` |
| Specs | `spec/requests/essence_spec.rb` |
