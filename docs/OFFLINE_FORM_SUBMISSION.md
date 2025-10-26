# Offline Form Submission

## Overview

Users can create happy things while offline! The app saves them locally and automatically syncs when internet connection returns.

## Features

### ✅ What Works Offline
- Creating new happy things
- Viewing previously cached happy things
- Seeing pending items immediately with visual indicators
- Automatic sync when connection returns

### ❌ What Doesn't Work Offline
- Photo uploads (will be lost if submitted offline)
- Editing existing happy things
- Viewing uncached pages
- Real-time updates from other users

## User Experience

### Creating a Happy Thing Offline

1. **User goes offline** (airplane mode, tunnel, poor connection)
   - Toast notification: "🔔 You're offline - some features may be limited"

2. **User fills out happy thing form and submits**
   - Form saves to local storage (IndexedDB)
   - Item appears immediately with special styling:
     - Dashed purple border
     - Slightly transparent (70% opacity)
     - "⏳ Pending sync..." indicator
   - Toast: "📝 Saved offline - will sync when online"

3. **User can create multiple happy things offline**
   - Each one is saved locally
   - Each one displays with pending indicator
   - All are queued for sync

4. **User comes back online**
   - Automatic sync triggered
   - All pending items POST to server
   - Successfully synced items removed from IndexedDB
   - Toast: "✅ Synced X happy thing(s)!"
   - Page reloads to show properly synced items

5. **If sync fails**
   - Items remain in IndexedDB
   - Will retry on next online event
   - User can manually trigger by going offline/online

## Technical Implementation

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│  (Happy Things Form + Container for Displaying Items)       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│            offline_form_controller.js (Stimulus)            │
│  • Intercepts form submissions                              │
│  • Checks navigator.onLine                                  │
│  • Routes to server OR IndexedDB                            │
│  • Displays pending items                                   │
│  • Syncs when online                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        ▼                              ▼
┌──────────────────┐          ┌─────────────────┐
│  Online Route    │          │  Offline Route  │
│                  │          │                 │
│  POST to server  │          │  Save to        │
│  with CSRF token │          │  IndexedDB      │
│                  │          │                 │
└──────────────────┘          └────────┬────────┘
                                       │
                                       ▼
                            ┌────────────────────┐
                            │  IndexedDB         │
                            │  (OfflineStorage)  │
                            │                    │
                            │  pendingHappyThings│
                            │  cachedHappyThings │
                            └────────────────────┘
```

### Key Files

1. **`app/javascript/utils/offline_storage.js`**
   - IndexedDB wrapper class
   - Database: `FiveThingsDB`
   - Stores pending items with metadata
   - Provides add, get, delete, sync methods

2. **`app/javascript/controllers/offline_form_controller.js`**
   - Stimulus controller
   - Handles form submission interception
   - Manages online/offline routing
   - Syncs pending items
   - Displays pending items in UI

3. **`public/service-worker.js`**
   - Intercepts POST requests
   - Registers background sync
   - Sends sync messages to clients

4. **`app/javascript/controllers/service_worker_controller.js`**
   - Listens for service worker messages
   - Dispatches custom events for sync triggers

### Data Flow

#### Offline Submission
```javascript
Form Submit (offline)
  ↓
prevent default
  ↓
Extract FormData (title, category_id, place, location, visibility)
  ↓
Save to IndexedDB with:
  - tempId: "temp-{timestamp}-{random}"
  - timestamp: now
  - synced: false
  ↓
Display on page with dashed border + opacity
  ↓
Show toast: "📝 Saved offline"
  ↓
Reset form
```

#### Online Sync
```javascript
Online event fires
  ↓
Get all pending items (synced: false)
  ↓
For each item:
  ↓
  Create FormData with all fields
  ↓
  POST to /happy_things
  ↓
  If success: delete from IndexedDB
  ↓
  If fail: keep in IndexedDB for retry
  ↓
Show toast: "✅ Synced X items"
  ↓
Reload page
```

### IndexedDB Schema

**Database:** `FiveThingsDB` (version 1)

**Store:** `pendingHappyThings`
- **Primary Key:** `id` (auto-increment)
- **Indexes:**
  - `timestamp` (creation time)
  - `synced` (boolean flag)

**Fields:**
```javascript
{
  id: 1,
  tempId: "temp-1234567890-abc123",
  title: "User's happy thing title",
  category_id: 2,
  latitude: 37.7749,
  longitude: -122.4194,
  place: "San Francisco",
  share_location: true,
  shared_with_ids: [3, 5, "group_7"],
  start_time: "2024-01-15T10:30:00.000Z",
  timestamp: 1705318200000,
  synced: false
}
```

## Integration Guide

### Add to a Form

1. **Update form HTML:**
```erb
<%= simple_form_for @happy_thing, html: {
  data: {
    controller: "offline-form",
    offline_form_target: "form",
    action: "submit->offline-form#submit"
  }
} do |f| %>
  <!-- form fields -->
<% end %>
```

2. **Add container for pending items:**
```erb
<div data-offline-form-target="container">
  <!-- Pending items will be inserted here -->
  <h3>Your Happy Things</h3>
  <%= render @happy_things %>
</div>
```

3. **Add parent controller:**
```erb
<div data-controller="offline-form">
  <!-- form and container -->
</div>
```

That's it! The controller will handle the rest.

## Styling

Pending items have special CSS:

```css
.offline-pending {
  opacity: 0.7;
  border: 2px dashed #95b7ff; /* soft purple */
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  background-color: #fafafa;
}
```

Toast notifications match app design:

```css
.pwa-toast {
  position: fixed;
  bottom: 16px;
  right: 16px;
  background: white;
  color: #95b7ff; /* soft purple */
  padding: 10px 20px;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  animation: slideUp 0.3s ease-out;
}
```

## Error Handling

### Network Errors During Online Submit
If submission fails while online (network error, server error):
```javascript
catch (error) {
  // Fall back to offline save
  await this.saveOffline(formData)
  this.showToast('⚠️ Network error - saved offline', 'warning')
}
```

### Sync Failures
If an item fails to sync:
```javascript
catch (error) {
  console.error('Failed to sync item:', error)
  // Item stays in IndexedDB
  // Will retry on next online event
}
```

### Photo Upload Offline
Photos cannot be stored offline (too large for IndexedDB):
```javascript
if (formData.get('happy_thing[photo]')?.size > 0) {
  this.showToast('⚠️ Photos cannot be uploaded offline', 'warning')
}
```

## Testing

### Manual Test Steps

1. **Test basic offline creation:**
```
1. Open app
2. Open DevTools → Network → Set to "Offline"
3. Create a happy thing
4. Verify:
   ✓ Item appears with dashed border
   ✓ Shows "⏳ Pending sync..."
   ✓ Toast: "📝 Saved offline"
   ✓ Form resets
```

2. **Test sync on reconnection:**
```
1. While offline, create 2-3 happy things
2. Go back online (Network → No throttling)
3. Wait 1-2 seconds
4. Verify:
   ✓ Toast: "✅ Synced X happy thing(s)!"
   ✓ Page reloads
   ✓ Items appear normally (no dashed border)
```

3. **Test persistence:**
```
1. Go offline
2. Create a happy thing
3. Close browser tab completely
4. Reopen app (still offline)
5. Verify:
   ✓ Pending item still visible
   ✓ Still has dashed border
6. Go online
7. Verify:
   ✓ Syncs automatically
```

4. **Test multiple offline sessions:**
```
1. Go offline, create item A
2. Go online, let it sync
3. Go offline, create item B
4. Go online, let it sync
5. Verify both items exist in database
```

5. **Test photo upload warning:**
```
1. Go offline
2. Try to upload a happy thing with a photo
3. Verify:
   ✓ Warning toast appears
   ✓ Item saves without photo
```

### Automated Testing

**Test file:** `spec/system/offline_form_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Offline Form Submission', type: :system, js: true do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'saves happy thing to IndexedDB when offline' do
    # Set up user and navigate to dashboard
    user = create(:user)
    login_as(user)
    visit dashboard_path
    
    # Go offline
    page.driver.browser.network_conditions = { offline: true }
    
    # Create happy thing
    fill_in 'Title', with: 'Offline Happy Thing'
    click_button 'Create Happy thing'
    
    # Verify offline save
    expect(page).to have_content('Pending sync')
    expect(page).to have_content('Saved offline')
    
    # Go online
    page.driver.browser.network_conditions = { offline: false }
    
    # Wait for sync
    sleep 2
    
    # Verify synced
    expect(page).to have_content('Synced 1 happy thing')
    expect(HappyThing.last.title).to eq('Offline Happy Thing')
  end
end
```

## Browser Support

| Feature | Chrome | Firefox | Safari | Edge |
|---------|--------|---------|--------|------|
| IndexedDB | ✅ 24+ | ✅ 16+ | ✅ 10+ | ✅ 12+ |
| Service Worker | ✅ 40+ | ✅ 44+ | ✅ 11.1+ | ✅ 17+ |
| Background Sync | ✅ 49+ | ❌ | ❌ | ✅ 79+ |
| navigator.onLine | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

**Note:** Background Sync API has limited support. The app falls back to the `online` event listener for browsers that don't support it.

## Troubleshooting

### Items not syncing

**Check IndexedDB:**
1. DevTools → Application → IndexedDB → FiveThingsDB
2. Inspect `pendingHappyThings` store
3. Look for items with `synced: false`

**Check console:**
1. Look for sync errors
2. Verify CSRF token is present
3. Check network requests

**Manual fix:**
```javascript
// In browser console:
const db = await window.indexedDB.open('FiveThingsDB', 1);
// Inspect stores manually
```

### Service worker not registering

**Verify registration:**
```javascript
navigator.serviceWorker.getRegistrations().then(registrations => {
  console.log('Registered workers:', registrations.length);
});
```

**Force re-register:**
1. DevTools → Application → Service Workers
2. Click "Unregister"
3. Reload page

### Form not intercepting

**Check controller connection:**
```javascript
// Should see in console:
[offline_form_controller.js] Connected
```

**Verify data attributes:**
```html
<!-- Form should have: -->
data-controller="offline-form"
data-offline-form-target="form"
data-action="submit->offline-form#submit"

<!-- Container should have: -->
data-offline-form-target="container"
```

## Future Improvements

- [ ] Support photo uploads offline (convert to base64)
- [ ] Add progress indicator during sync
- [ ] Show sync queue status in navbar badge
- [ ] Add "Retry sync" button for manual trigger
- [ ] Support editing items offline
- [ ] Conflict resolution for concurrent edits
- [ ] Compress data before storing in IndexedDB
- [ ] Implement periodic sync (every hour)
- [ ] Add offline analytics
- [ ] Cache API responses for faster offline browsing
