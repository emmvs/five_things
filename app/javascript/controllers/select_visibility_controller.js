import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="select-visibility"
export default class extends Controller {
  static values = { options: Object }

  connect() {
    const baseOptions = {
      plugins: {
        remove_button: {
          title: "Remove this item"
        }
      },
      create: true,
      persist: false
    }

    const mergedOptions = {
      ...baseOptions,
      ...(this.optionsValue || {})
    }

    new TomSelect(this.element, mergedOptions)

    // Optional: hide original select element (TomSelect replaces it visually)
    this.element.style.display = "none"
  }
}