# PWA Offline Functionality

## Features

### 🔌 Offline Support
The app works offline using a Service Worker with a **Network First** caching strategy:

- **Network First**: Always tries to fetch fresh content from the network
- **Cache Fallback**: If network fails, serves cached version
- **Offline Page**: Shows a friendly offline page when no cached version exists

### 📱 Installation
Users can install the app on their device:
- **iOS**: Tap Share → Add to Home Screen
- **Android**: Tap Menu → Install App / Add to Home Screen
- **Desktop**: Click install button in address bar

### 🔄 Auto-Updates
- Service Worker checks for updates every hour
- Users are prompted to refresh when a new version is available
- Old cache is automatically cleaned up

### 🌐 Network Status
- Shows toast notification when going offline/online
- Auto-reloads when connection is restored from offline page

## How It Works

### Service Worker (`public/service-worker.js`)
```javascript
// 1. Install: Caches static assets
// 2. Activate: Cleans up old caches
// 3. Fetch: Network first, cache fallback strategy
```

### Stimulus Controller (`app/javascript/controllers/service_worker_controller.js`)
- Registers the service worker
- Monitors online/offline status
- Shows update notifications
- Displays network status toasts

### Offline Page (`public/offline.html`)
- Standalone page that works without network
- Auto-reloads when connection returns
- Matches app branding

## Cache Strategy

**Network First** is ideal for this app because:
- Users always see the latest happy things when online
- Content is still accessible when offline
- Updates happen automatically when network returns

## Testing Offline Mode

### Chrome DevTools
1. Open DevTools → Application → Service Workers
2. Check "Offline" checkbox
3. Reload page to test offline experience

### iOS/Android
1. Enable Airplane Mode
2. Open the installed PWA
3. Navigate through cached pages

## Cache Management

The service worker:
- Caches successful GET requests automatically
- Skips POST/PUT/DELETE (mutations)
- Cleans up old cache versions on activate
- Uses versioned cache names (`five-things-v1`)

To force cache refresh:
```javascript
// Increment CACHE_VERSION in service-worker.js
const CACHE_VERSION = 'v2';
```

## Future Enhancements

Potential improvements:
- [ ] Cache happy thing images with Cloudinary
- [ ] Offline form submission queue (background sync)
- [ ] IndexedDB for local data storage
- [ ] Selective caching (cache only recent happy things)
- [ ] Push notifications for friend activity
