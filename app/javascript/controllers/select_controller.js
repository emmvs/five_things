import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="select"
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
      persist: false,
      onDelete: (values) => {
        return confirm(
          values.length > 1
            ? `Are you sure you want to remove these ${values.length} items?`
            : `Are you sure you want to remove "${values[0]}"?`
        );
      }
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
