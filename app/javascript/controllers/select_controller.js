import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = { placeholder: String }

  connect() {
    new TomSelect(this.element, {
      plugins: { remove_button: { title: "Remove" } },
      placeholder: this.placeholderValue || "",
      allowEmptyOption: false
    })
  }
}
