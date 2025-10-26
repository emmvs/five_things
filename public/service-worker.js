const CACHE_VERSION = 'v1';
const CACHE_NAME = `five-things-${CACHE_VERSION}`;

// Assets to cache on install
const STATIC_ASSETS = [
  '/',
  '/offline.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
  '/apple-touch-icon.png'
];

// Install event - cache static assets
self.addEventListener('install', event => {
  console.log('[Service Worker] Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => self.skipWaiting()) // Activate immediately
  );
});

// Activate event - cleanup old caches
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('[Service Worker] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim()) // Take control immediately
  );
});

// Fetch event - network first, fallback to cache
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Handle POST requests (form submissions)
  if (request.method === 'POST') {
    event.respondWith(handlePostRequest(request));
    return;
  }

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  event.respondWith(
    networkFirstStrategy(request)
  );
});

// Handle POST requests for offline functionality
async function handlePostRequest(request) {
  try {
    // Try to submit to server
    const response = await fetch(request.clone());
    return response;
  } catch (error) {
    // If offline, register for background sync
    console.log('[Service Worker] POST request failed, will retry when online');
    
    // Clone and store the request for later
    if ('sync' in self.registration) {
      await self.registration.sync.register('sync-happy-things');
    }
    
    // Return a response indicating offline save
    return new Response(
      JSON.stringify({ 
        status: 'pending',
        message: 'Saved offline, will sync when online'
      }),
      {
        status: 202,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
}

// Background Sync event - sync pending items when back online
self.addEventListener('sync', event => {
  if (event.tag === 'sync-happy-things') {
    console.log('[Service Worker] Background sync triggered');
    event.waitUntil(syncPendingItems());
  }
});

async function syncPendingItems() {
  // Notify the client to sync via IndexedDB
  const clients = await self.clients.matchAll();
  clients.forEach(client => {
    client.postMessage({
      type: 'SYNC_PENDING_ITEMS'
    });
  });
}

// Network first strategy with cache fallback
async function networkFirstStrategy(request) {
  try {
    // Try network first
    const networkResponse = await fetch(request);
    
    // Cache successful responses
    if (networkResponse.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    // Network failed, try cache
    console.log('[Service Worker] Network failed, checking cache:', request.url);
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // If HTML page and not cached, show offline page
    if (request.headers.get('accept').includes('text/html')) {
      return caches.match('/offline.html');
    }
    
    // For other resources, return error
    return new Response('Network error happened', {
      status: 408,
      headers: { 'Content-Type': 'text/plain' }
    });
  }
}
