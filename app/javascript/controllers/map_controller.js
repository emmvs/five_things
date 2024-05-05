import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    lat: Number,       // Single marker latitude
    lng: Number,       // Single marker longitude
    markers: Array     // Array of markers
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    // Decide initial center and zoom based on provided data
    let center = [this.lngValue || -0.1276, this.latValue || 51.5072]; // Default to London Coordinates if not provided
    let zoom = this.hasMarkersValue ? 5 : 15; // Zoom out if multiple markers, zoom in for single marker

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10",
      center: center,
      zoom: zoom
    });

    if (this.hasMarkersValue && this.markersValue.length > 0) {
      this.#addMarkersToMap();
    } else {
      this.#addMarkerToMap();
    }
  }

  #addMarkerToMap() {
    new mapboxgl.Marker()
      .setLngLat([this.lngValue, this.latValue])
      .addTo(this.map);
  }

  #addMarkersToMap() {
    this.markersValue.forEach(marker => {
      new mapboxgl.Marker()
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map);
    });
    this.#fitMapToBounds();
  }

  #fitMapToBounds() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]));
    this.map.fitBounds(bounds, { padding: 20 });
  }
}
