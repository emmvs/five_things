import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hello"];
  connect() {
    // this.element.textContent = "Hello World!";
    console.log("hello from stimulus");
    console.log(this.helloTarget);
  }
}
