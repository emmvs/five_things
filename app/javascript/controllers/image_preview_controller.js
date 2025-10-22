import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "old_avatar"]

  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      this.previewTarget.src = URL.createObjectURL(file)
      this.previewTarget.style.display = 'block'
    }
  }

  edit() {
    const file = this.inputTarget.files[0]
    if (file) {
      this.previewTarget.src = URL.createObjectURL(file)
      this.old_avatarTarget.style.display = 'none'
      this.previewTarget.style.display = 'block'
    }
  }
}
