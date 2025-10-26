import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pwa-detector"
export default class extends Controller {
  connect() {
    this.detectPWAMode()
    this.checkSessionPersistence()
  }

  detectPWAMode() {
    // Check if running in standalone mode (installed PWA)
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches
      || window.navigator.standalone // iOS
      || document.referrer.includes('android-app://') // Android TWA

    if (isStandalone) {
      console.log('[PWA] Running in standalone mode')
      document.body.classList.add('pwa-standalone')
      
      // Store that user is using PWA
      localStorage.setItem('isPWA', 'true')
    }
  }

  checkSessionPersistence() {
    // Check if user logged in from PWA and session expired
    const isPWA = localStorage.getItem('isPWA') === 'true'
    const isLoginPage = window.location.pathname.includes('/users/sign_in')
    
    if (isPWA && isLoginPage) {
      // Show helpful message about keeping logged in
      this.showPWALoginHint()
    }
  }

  showPWALoginHint() {
    const form = document.querySelector('form')
    if (!form) return

    // Check if hint already exists
    if (document.querySelector('.pwa-login-hint')) return

    const hint = document.createElement('div')
    hint.className = 'pwa-login-hint'
    hint.style.cssText = `
      background: #fff3cd;
      color: #856404;
      padding: 12px 16px;
      border-radius: 4px;
      margin-bottom: 16px;
      font-size: 0.9rem;
      border-left: 4px solid #8E44AD;
    `
    hint.innerHTML = `
      <strong>📱 Using the app from your home screen?</strong><br>
      Make sure "Keep me logged in" is checked so you don't have to log in every time!
    `

    form.insertBefore(hint, form.firstChild)
  }
}
