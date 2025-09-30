import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      this.previewTarget.src = URL.createObjectURL(file)
      this.previewTarget.style.display = 'block'
    }
  }
}
