import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // console.log('Service worker controller connected')
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/service-worker.js')
        .then(registration => {
          // console.log('ServiceWorker registration successful with scope: ', registration.scope);
        })
        .catch(err => {
          // console.log('ServiceWorker registration failed: ', err);
        });
    }
  }
}
