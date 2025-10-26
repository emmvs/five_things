import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-worker"
export default class extends Controller {
  connect() {
    if ('serviceWorker' in navigator) {
      this.registerServiceWorker()
      this.setupOfflineDetection()
      this.listenForServiceWorkerMessages()
    }
  }

  async registerServiceWorker() {
    try {
      const registration = await navigator.serviceWorker.register('/service-worker.js')
      console.log('[PWA] Service Worker registered:', registration.scope)
      
      // Check for updates
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing
        
        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            this.showUpdateNotification()
          }
        })
      })
      
      // Check for updates every hour
      setInterval(() => {
        registration.update()
      }, 60 * 60 * 1000)
      
    } catch (err) {
      console.error('[PWA] Service Worker registration failed:', err)
    }
  }

  listenForServiceWorkerMessages() {
    navigator.serviceWorker.addEventListener('message', event => {
      if (event.data.type === 'SYNC_PENDING_ITEMS') {
        console.log('[PWA] Received sync request from service worker')
        // Dispatch custom event that offline_form_controller can listen to
        window.dispatchEvent(new CustomEvent('service-worker-sync'))
      }
    })
  }

  setupOfflineDetection() {
    window.addEventListener('online', () => {
      this.showOnlineStatus(true)
    })
    
    window.addEventListener('offline', () => {
      this.showOnlineStatus(false)
    })
    
    // Check initial status
    if (!navigator.onLine) {
      this.showOnlineStatus(false)
    }
  }

  showOnlineStatus(isOnline) {
    const message = isOnline 
      ? '🚀 You\'re back online!' 
      : '🔔 You\'re offline - some features may be limited'
    
    this.showToast(message, isOnline ? 'success' : 'warning')
  }

  showUpdateNotification() {
    const shouldUpdate = confirm(
      '🎉 A new version of 5 Things is available!\n\nWould you like to update now?'
    )
    
    if (shouldUpdate) {
      window.location.reload()
    }
  }

  showToast(message, type = 'info') {
    // Create toast element matching app's alert styling
    const toast = document.createElement('div')
    toast.textContent = message
    toast.className = 'pwa-toast'
    toast.style.cssText = `
      position: fixed;
      bottom: 16px;
      right: 16px;
      background: white;
      color: #8E44AD;
      padding: 10px 20px;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      z-index: 100;
      font-size: 0.9rem;
      animation: slideUp 0.3s ease-out;
      max-width: 300px;
    `
    
    document.body.appendChild(toast)
    
    // Remove after 3 seconds
    setTimeout(() => {
      toast.style.animation = 'slideDown 0.3s ease-out'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
