import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["togglableElement"]

  fire() {
    // console.log(this.togglableElementTarget)
    this.togglableElementTarget.classList.toggle("d-none");
  }
}
