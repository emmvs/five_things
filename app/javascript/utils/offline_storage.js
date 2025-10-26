// IndexedDB helper for offline storage
class OfflineStorage {
  constructor() {
    this.dbName = 'FiveThingsDB'
    this.version = 1
    this.db = null
  }

  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, this.version)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        this.db = request.result
        resolve(this.db)
      }

      request.onupgradeneeded = (event) => {
        const db = event.target.result

        // Store for pending happy things
        if (!db.objectStoreNames.contains('pendingHappyThings')) {
          const store = db.createObjectStore('pendingHappyThings', { 
            keyPath: 'id', 
            autoIncrement: true 
          })
          store.createIndex('timestamp', 'timestamp', { unique: false })
          store.createIndex('synced', 'synced', { unique: false })
        }

        // Store for cached happy things
        if (!db.objectStoreNames.contains('cachedHappyThings')) {
          const store = db.createObjectStore('cachedHappyThings', { 
            keyPath: 'id'
          })
          store.createIndex('start_time', 'start_time', { unique: false })
        }
      }
    })
  }

  async addPendingHappyThing(data) {
    const transaction = this.db.transaction(['pendingHappyThings'], 'readwrite')
    const store = transaction.objectStore('pendingHappyThings')
    
    const happyThing = {
      ...data,
      timestamp: new Date().toISOString(),
      synced: false,
      tempId: `temp-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    }

    return new Promise((resolve, reject) => {
      const request = store.add(happyThing)
      request.onsuccess = () => resolve({ ...happyThing, id: request.result })
      request.onerror = () => reject(request.error)
    })
  }

  async getPendingHappyThings() {
    const transaction = this.db.transaction(['pendingHappyThings'], 'readonly')
    const store = transaction.objectStore('pendingHappyThings')
    const index = store.index('synced')
    
    return new Promise((resolve, reject) => {
      const request = index.getAll(false) // Get unsynced items
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  async markAsSynced(id) {
    const transaction = this.db.transaction(['pendingHappyThings'], 'readwrite')
    const store = transaction.objectStore('pendingHappyThings')
    
    return new Promise((resolve, reject) => {
      const request = store.get(id)
      request.onsuccess = () => {
        const data = request.result
        data.synced = true
        const updateRequest = store.put(data)
        updateRequest.onsuccess = () => resolve()
        updateRequest.onerror = () => reject(updateRequest.error)
      }
      request.onerror = () => reject(request.error)
    })
  }

  async deletePendingHappyThing(id) {
    const transaction = this.db.transaction(['pendingHappyThings'], 'readwrite')
    const store = transaction.objectStore('pendingHappyThings')
    
    return new Promise((resolve, reject) => {
      const request = store.delete(id)
      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  async cacheHappyThing(happyThing) {
    const transaction = this.db.transaction(['cachedHappyThings'], 'readwrite')
    const store = transaction.objectStore('cachedHappyThings')
    
    return new Promise((resolve, reject) => {
      const request = store.put(happyThing)
      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  async getTodaysHappyThings() {
    const transaction = this.db.transaction(['cachedHappyThings'], 'readonly')
    const store = transaction.objectStore('cachedHappyThings')
    const index = store.index('start_time')
    
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)
    
    return new Promise((resolve, reject) => {
      const range = IDBKeyRange.bound(today.toISOString(), tomorrow.toISOString(), false, true)
      const request = index.getAll(range)
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }
}

export default OfflineStorage
