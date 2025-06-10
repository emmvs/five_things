import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-location"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.formTarget.addEventListener("submit", (event) => {
      const shareLocationCheckbox = this.formTarget.querySelector('input[name="happy_thing[share_location]"]');
      if (shareLocationCheckbox && shareLocationCheckbox.checked) {
        event.preventDefault();
        this.getLocation(() => this.formTarget.submit());
      }
    });
  }

  toggle(event) {
    if (event.target.checked) {
      this.getLocation();
    } else {
      this.resetLocationInputs();
    }
  }

  getLocation(callback) {
    if (!navigator.geolocation) {
      if (callback) callback();
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.setHiddenInput("happy_thing[latitude]", position.coords.latitude);
        this.setHiddenInput("happy_thing[longitude]", position.coords.longitude);

        // optional: fetch rough city name from lat/lng
        this.reverseGeocode(position.coords.latitude, position.coords.longitude);

        if (callback) callback();
      },
      (error) => {
        console.error("Geolocation failed", error);
        if (callback) callback();
      }
    );
  }

  setHiddenInput(name, value) {
    let input = this.formTarget.querySelector(`input[name="${name}"]`);
    if (!input) {
      input = document.createElement("input");
      input.type = "hidden";
      input.name = name;
      this.formTarget.appendChild(input);
    }
    input.value = value;
  }

  reverseGeocode(lat, lon) {
    fetch(`https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`)
      .then(response => response.json())
      .then(data => {
        const city = data?.address?.city || data?.address?.town || data?.address?.village || "";
        this.setHiddenInput("happy_thing[place]", city);
      })
      .catch(() => {
        this.setHiddenInput("happy_thing[place]", "Unknown");
      });
  }
}
