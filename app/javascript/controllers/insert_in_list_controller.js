import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="insert-in-list"
export default class extends Controller {
  static targets = ["items", "form"]

  connect() {
    console.log("👻 element", this.element)
    console.log("👻 form", this.formTarget)
  }

  send(event) {
    event.preventDefault();
  
    fetch(this.formTarget.action, {
      method: "POST",
      headers: { "Accept": "application/json" },
      body: new FormData(this.formTarget)
    })
      .then(response => response.json())
      .then((data) => {
        console.log(data.inserted_item);
        if (data.inserted_item) {
          console.log("👻 itemsTarget", this.itemsTarget)
          this.itemsTarget.insertAdjacentHTML("beforeend", data.inserted_item);
          this.resetForm();
        }
        this.formTarget.outerHTML = data.form;
      })
  }

  resetForm() {
    this.formTarget.reset();
  }
}
