# PWA Authentication & Session Persistence

## The Problem

When users install your PWA to their home screen and open it, they often get logged out or have to log in frequently. This happens because:

1. **Different browser context**: PWAs run in standalone mode, which some browsers treat as a separate browsing context
2. **Session cookies expire**: Default session cookies are short-lived (close browser = logged out)
3. **Cookie SameSite restrictions**: Strict cookie policies can prevent cookies from working in standalone mode

## The Solution

We've implemented several fixes to keep users logged in when using the PWA:

### 1. Extended Session Duration

**File:** `config/initializers/session_store.rb`

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_five_things_session',
  expire_after: 1.year,      # Keep session alive for 1 year
  same_site: :lax,           # Required for PWA standalone mode
  secure: Rails.env.production?,
  httponly: true
```

- Sessions last **1 year** instead of expiring on browser close
- `same_site: :lax` allows cookies to work in PWA standalone mode
- `secure: true` in production ensures HTTPS-only cookies
- `httponly: true` prevents JavaScript access (security)

### 2. Devise Remember Me Configuration

**File:** `config/initializers/devise.rb`

```ruby
config.remember_for = 1.year
config.extend_remember_period = true
config.rememberable_options = {
  secure: Rails.env.production?,
  same_site: :lax
}
```

- Remember me tokens last **1 year**
- `extend_remember_period = true` refreshes the token on each visit
- Same PWA-friendly cookie settings as session store

### 3. Auto-Check "Remember Me" on Login

**File:** `app/views/devise/sessions/new.html.erb`

The "Keep me logged in" checkbox is now:
- ✅ **Checked by default**
- Better label: "Keep me logged in" (clearer than "Remember me")
- Users can still uncheck if they want (public computers, etc.)

### 4. PWA Detection & Login Hints

**File:** `app/javascript/controllers/pwa_detector_controller.js`

Detects when users are accessing from installed PWA and shows a helpful hint on the login page:

```
📱 Using the app from your home screen?
Make sure "Keep me logged in" is checked so you don't have to log in every time!
```

Detection methods:
- `display-mode: standalone` media query (most browsers)
- `window.navigator.standalone` (iOS Safari)
- `android-app://` referrer (Android TWA)

## User Flow

### First Time Installing PWA

1. User visits app in browser
2. Clicks "Add to Home Screen"
3. Opens app from home screen
4. Sees login page with hint about "Keep me logged in"
5. Logs in with checkbox checked (default)
6. **Stays logged in for 1 year** (or until they explicitly log out)

### Subsequent Opens

1. User opens PWA from home screen
2. Already logged in - goes straight to dashboard
3. Each visit extends the session/remember token
4. No need to log in again unless:
   - They manually log out
   - They clear browser data/cookies
   - 1 year passes without using the app

## Technical Details

### Cookie Storage

Both session and remember_me cookies are stored:

**Session Cookie:**
- Name: `_five_things_session`
- Duration: 1 year
- Contains: Encrypted session data (user_id, CSRF token, etc.)
- Renewal: Automatic on each request

**Remember Me Cookie:**
- Name: `remember_user_token`
- Duration: 1 year (extended on each visit)
- Contains: Encrypted remember token
- Renewal: Extended with each authenticated request

### Security Considerations

✅ **Good practices maintained:**
- HTTPS-only cookies in production (`secure: true`)
- HTTP-only cookies prevent XSS attacks (`httponly: true`)
- CSRF protection still active
- Users can still choose to log out
- Tokens are encrypted

⚠️ **Trade-offs:**
- Longer session duration = longer window if device is stolen
- Mitigation: Encourage users to lock their devices
- Acceptable for personal app (not banking/financial)

### Browser Compatibility

| Browser | Standalone Mode | Session Persistence | Remember Me |
|---------|----------------|---------------------|-------------|
| iOS Safari 11.3+ | ✅ Yes | ✅ Yes | ✅ Yes |
| Chrome/Edge (Android) | ✅ Yes | ✅ Yes | ✅ Yes |
| Samsung Internet | ✅ Yes | ✅ Yes | ✅ Yes |
| Firefox (Android) | ⚠️ Limited | ✅ Yes | ✅ Yes |

## Testing

### Test PWA Session Persistence

1. **Initial setup:**
   ```
   - Install PWA to home screen
   - Open from home screen
   - Log in with "Keep me logged in" checked
   - Close app completely
   ```

2. **Test persistence:**
   ```
   - Wait 5 minutes
   - Open PWA from home screen
   - Should go directly to dashboard (no login)
   ```

3. **Test after long period:**
   ```
   - Don't open app for several days
   - Open PWA from home screen
   - Should still be logged in
   ```

4. **Test explicit logout:**
   ```
   - Log out from menu
   - Close app
   - Reopen
   - Should require login (as expected)
   ```

### Test in Browser DevTools

**Inspect cookies:**
```
1. Open DevTools → Application → Cookies
2. Look for:
   - _five_things_session (should have far-future expiry)
   - remember_user_token (if remember me was checked)
3. Verify SameSite=Lax
```

**Test standalone mode detection:**
```javascript
// In console:
window.matchMedia('(display-mode: standalone)').matches
// Should be true when installed as PWA
```

## Troubleshooting

### Users Still Getting Logged Out

**1. Check cookies are being set:**
- DevTools → Application → Cookies
- Verify `_five_things_session` exists with 1-year expiry

**2. Check SameSite attribute:**
- Cookie should have `SameSite=Lax`
- If `SameSite=Strict`, sessions won't work in PWA

**3. Check HTTPS in production:**
- PWAs require HTTPS
- Secure cookies only work over HTTPS

**4. Check browser storage limits:**
- Some browsers limit cookie size/count
- Clear old/unused cookies

### Remember Me Not Working

**1. Verify checkbox is checked:**
- Default is checked, but users can uncheck
- Check network tab: POST to /users/sign_in should include `user[remember_me]=1`

**2. Check Devise configuration:**
```ruby
# Should be in config/initializers/devise.rb
config.remember_for = 1.year
config.extend_remember_period = true
```

**3. Check database:**
```ruby
# In Rails console:
user = User.find_by(email: 'test@example.com')
user.remember_created_at
# Should show a recent timestamp if remember me is active
```

### PWA Detection Not Working

**1. Verify standalone mode:**
```javascript
// In console:
window.matchMedia('(display-mode: standalone)').matches
```

**2. Check controller connection:**
```javascript
// Should see in console:
[PWA] Running in standalone mode
```

**3. iOS specific:**
```javascript
// Check:
window.navigator.standalone
// Should be true on iOS PWA
```

## Migration Notes

If you already have existing users:

1. **They'll need to log in once more** to get the new remember_me token
2. **Remind them to check "Keep me logged in"** when they do
3. **Consider showing a one-time banner** explaining the improvement

## Future Enhancements

- [ ] Add biometric authentication (Face ID, Touch ID, fingerprint)
- [ ] Add "Trust this device" option for extra security
- [ ] Implement session activity monitoring
- [ ] Add "Active sessions" page where users can see/revoke access
- [ ] Consider refresh tokens for even longer sessions
- [ ] Add option to require re-auth for sensitive actions (changing password, etc.)

## Related Files

- `config/initializers/session_store.rb` - Session cookie configuration
- `config/initializers/devise.rb` - Devise remember me settings
- `app/views/devise/sessions/new.html.erb` - Login form with checked remember me
- `app/javascript/controllers/pwa_detector_controller.js` - PWA detection and hints
- `public/manifest.json` - PWA manifest with scope and start URL
