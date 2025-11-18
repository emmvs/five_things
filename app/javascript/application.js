// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// ! Disable Turbo Drive on the whole app
// import { Turbo } from "@hotwired/turbo-rails"
// Turbo.session.drive = false

import "bootstrap"
import "@popperjs/core"

window.capturedNativePrompt = null;
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  window.capturedNativePrompt = e;
});
