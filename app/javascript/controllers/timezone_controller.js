import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timezoneOffset"]

  connect() {
    var offset = new Date().getTimezoneOffset();
    this.timezoneOffsetTarget.value = offset;
  }
}
