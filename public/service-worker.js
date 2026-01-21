self.addEventListener('install', event => {
  // console.log('Service worker installing...');
  // Put your assets caching logic here
});

self.addEventListener('activate', event => {
  event.waitUntil(clients.claim());
  // console.log('Service worker activated.');
});

self.addEventListener('fetch', event => {
  // console.log('Fetch/ing:', event.request.url);
  // Put your fetching and caching logic here
});
