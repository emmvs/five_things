import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading"
export default class extends Controller {
  connect() {
    if (localStorage.getItem("loadingScreenShown")) {
      this.element.style.display = "none";
    } else {
      this.element.addEventListener("animationend", this.removeElement);
    }
  }

  disconnect() {
    this.element.removeEventListener("animationend", this.removeElement);
  }

  removeElement = () => {
    this.element.remove();
    localStorage.setItem("loadingScreenShown", "true");
  };
}
