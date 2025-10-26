import { Controller } from "@hotwired/stimulus"
import OfflineStorage from "../utils/offline_storage"

export default class extends Controller {
  static targets = ["form", "container"]

  async connect() {
    this.storage = new OfflineStorage()
    await this.storage.init()
    
    // Display any pending items from previous sessions
    this.displayPendingItems()
    
    // Listen for when we come back online
    window.addEventListener('online', () => this.syncPendingItems())
    
    // Listen for service worker sync messages
    window.addEventListener('service-worker-sync', () => this.syncPendingItems())
  }

  async submit(event) {
    event.preventDefault() // Always prevent default to handle submission ourselves
    
    const form = event.target
    const formData = new FormData(form)
    
    if (navigator.onLine) {
      await this.submitToServer(form, formData)
    } else {
      await this.saveOffline(formData)
    }
  }

  async submitToServer(form, formData) {
    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        // Success - reload page to show new item
        window.location.reload()
      } else {
        console.error('[Offline Form] Server error:', response.status)
        this.showToast('❌ Error saving. Please try again.', 'error')
      }
    } catch (error) {
      console.error('[Offline Form] Network error:', error)
      // If failed to submit, save offline instead
      await this.saveOffline(formData)
    }
  }

  async saveOffline(formData) {
    // Extract form data - note: photos can't be stored offline easily
    const data = {
      title: formData.get('happy_thing[title]'),
      category_id: formData.get('happy_thing[category_id]'),
      latitude: formData.get('happy_thing[latitude]'),
      longitude: formData.get('happy_thing[longitude]'),
      place: formData.get('happy_thing[place]'),
      share_location: formData.get('happy_thing[share_location]'),
      shared_with_ids: formData.getAll('happy_thing[shared_with_ids][]'),
      start_time: new Date().toISOString()
    }

    // Note: Photo uploads are not supported offline
    if (formData.get('happy_thing[photo]')?.size > 0) {
      this.showToast('⚠️ Photos cannot be uploaded offline. They will be lost.', 'warning')
    }

    // Save to IndexedDB
    const savedItem = await this.storage.addPendingHappyThing(data)
    
    // Add to page with temp styling
    this.addPendingItemToPage(savedItem)
    
    // Reset form
    this.formTarget.reset()
    
    // Show offline message
    this.showToast('📝 Saved offline - will sync when online', 'warning')
  }

  async syncPendingItems() {
    const pendingItems = await this.storage.getPendingHappyThings()
    
    if (pendingItems.length === 0) return

    console.log(`Syncing ${pendingItems.length} pending items...`)
    
    let synced = 0
    for (const item of pendingItems) {
      try {
        await this.syncItem(item)
        await this.storage.deletePendingHappyThing(item.id)
        synced++
      } catch (error) {
        console.error('Failed to sync item:', error)
      }
    }

    if (synced > 0) {
      this.showToast(`✅ Synced ${synced} happy thing(s)!`, 'success')
      
      // Reload to show synced items properly
      setTimeout(() => window.location.reload(), 1000)
    }
  }

  async syncItem(item) {
    const formData = new FormData()
    formData.append('happy_thing[title]', item.title)
    formData.append('happy_thing[start_time]', item.start_time)
    
    if (item.category_id) formData.append('happy_thing[category_id]', item.category_id)
    if (item.place) formData.append('happy_thing[place]', item.place)
    if (item.latitude) formData.append('happy_thing[latitude]', item.latitude)
    if (item.longitude) formData.append('happy_thing[longitude]', item.longitude)
    if (item.share_location) formData.append('happy_thing[share_location]', item.share_location)
    
    // Handle multiple shared_with_ids
    if (item.shared_with_ids && Array.isArray(item.shared_with_ids)) {
      item.shared_with_ids.forEach(id => {
        if (id) formData.append('happy_thing[shared_with_ids][]', id)
      })
    }

    const response = await fetch('/happy_things', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })

    if (!response.ok) {
      throw new Error('Sync failed')
    }

    return await response.json()
  }

  async displayPendingItems() {
    const pendingItems = await this.storage.getPendingHappyThings()
    
    pendingItems.forEach(item => {
      this.addPendingItemToPage(item)
    })

    if (pendingItems.length > 0) {
      this.showToast(`📱 ${pendingItems.length} item(s) pending sync`, 'warning')
    }
  }

  addPendingItemToPage(item) {
    const container = this.containerTarget
    if (!container) return

    // Find where to insert (after the heading)
    const heading = container.querySelector('h3')
    
    const card = document.createElement('div')
    card.className = 'happy-thing-card offline-pending'
    card.dataset.tempId = item.tempId
    card.style.opacity = '0.7'
    card.style.border = '2px dashed #95b7ff'
    card.style.borderRadius = '8px'
    card.style.padding = '16px'
    card.style.marginBottom = '16px'
    card.style.backgroundColor = '#fafafa'
    
    card.innerHTML = `
      <div>
        <h5 style="margin-bottom: 8px;">${this.escapeHtml(item.title)}</h5>
        ${item.place ? `<p class="text-muted" style="margin-bottom: 4px;">📍 ${this.escapeHtml(item.place)}</p>` : ''}
        <small class="text-muted">⏳ Pending sync...</small>
      </div>
    `
    
    // Insert after heading
    if (heading && heading.nextSibling) {
      container.insertBefore(card, heading.nextSibling)
    } else {
      container.appendChild(card)
    }
  }

  addHappyThingToPage(happyThing) {
    // This would be customized based on your actual page structure
    const container = this.containerTarget
    if (!container) return

    // Remove temp version if exists
    const tempCard = container.querySelector(`[data-temp-id="${happyThing.tempId}"]`)
    if (tempCard) tempCard.remove()

    // Add real version (you'd customize this HTML to match your design)
    const card = document.createElement('div')
    card.className = 'happy-thing-card'
    card.innerHTML = `
      <div class="card p-3 my-3">
        <h5>${this.escapeHtml(happyThing.title)}</h5>
        ${happyThing.body ? `<p>${this.escapeHtml(happyThing.body)}</p>` : ''}
        ${happyThing.place ? `<p class="text-muted">📍 ${this.escapeHtml(happyThing.place)}</p>` : ''}
      </div>
    `
    
    container.insertBefore(card, container.firstChild)
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  showToast(message, type = 'info') {
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
    
    setTimeout(() => {
      toast.style.animation = 'slideDown 0.3s ease-out'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
