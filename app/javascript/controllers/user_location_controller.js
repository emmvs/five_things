import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-location"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("connected lol 👻");
    this.formTarget.addEventListener("submit", event => {
      event.preventDefault();
      this.getLocation();
    });
  }

  getLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        position => this.submitFormWithLocation(position),
        error => console.error('Error obtaining location', error)
      );
    } else {
      console.error("Geolocation is not supported by this browser.");
      this.formTarget.submit(); // Fallback: submit form without location
    }
  }

  submitFormWithLocation(position) {
    const latitudeInput = document.createElement("input");
    latitudeInput.type = "hidden";
    latitudeInput.name = "happy_thing[latitude]";
    latitudeInput.value = position.coords.latitude;

    const longitudeInput = document.createElement("input");
    longitudeInput.type = "hidden";
    longitudeInput.name = "happy_thing[longitude]";
    longitudeInput.value = position.coords.longitude;

    this.formTarget.appendChild(latitudeInput);
    this.formTarget.appendChild(longitudeInput);
    this.formTarget.submit();
  }
}
