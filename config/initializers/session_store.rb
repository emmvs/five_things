# frozen_string_literal: true

# Configure session store for PWA compatibility
# PWAs in standalone mode need persistent sessions to avoid constant re-authentication

Rails.application.config.session_store :cookie_store,
  key: '_five_things_session',
  expire_after: 1.year,      # Keep session alive for 1 year
  same_site: :lax,           # Required for PWA standalone mode
  secure: Rails.env.production?, # HTTPS only in production
  httponly: true             # Security: prevent JavaScript access
