import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = { placeholder: String }

  connect() {
    const placeholder = this.placeholderValue || ""

    this.tom = new TomSelect(this.element, {
      plugins: { remove_button: { title: "Remove" } },
      placeholder,
      allowEmptyOption: false,
      onItemAdd: () => setTimeout(() => this.#updatePlaceholder(), 0),
      onItemRemove: () => setTimeout(() => this.#updatePlaceholder(), 0)
    })
  }

  #updatePlaceholder() {
    const input = this.tom.control_input
    if (this.tom.items.length > 0) {
      input.placeholder = ""
      input.style.width = "0"
    } else {
      input.placeholder = this.placeholderValue || ""
      input.style.width = ""
    }
  }
}
