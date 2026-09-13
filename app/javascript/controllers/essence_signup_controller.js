import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "step1",
    "step2",
    "heading1",
    "heading2",
    "nameInput",
    "emailInput",
    "inputContainer1",
    "inputContainer2",
    "form",
    "errorMessage",
  ];

  static values = {
    greeting: String,
    nameQuestion: String,
    nameReply: String,
    emailQuestion: String,
    farewell: String,
    url: String,
  };

  connect() {
    this.currentStep = 1;
    this.typewriterEffect(1);
  }

  showText(element, text, duration) {
    return new Promise((resolve) => {
      element.textContent = text;
      element.style.transition = "none";
      element.style.opacity = "0";

      void element.offsetHeight;

      requestAnimationFrame(() => {
        element.style.transition = "opacity 0.8s ease-in-out";
        element.style.opacity = "1";

        setTimeout(() => {
          element.style.opacity = "0";
          setTimeout(resolve, 800);
        }, duration);
      });
    });
  }

  async typewriterEffect(step) {
    const headingTarget = this[`heading${step}Target`];
    const inputContainer = this[`inputContainer${step}Target`];

    if (step === 1) {
      await this.showText(headingTarget, this.greetingValue, 2000);
      await new Promise((resolve) => setTimeout(resolve, 800));
      await this.showText(headingTarget, this.nameQuestionValue, 2000);
    } else {
      const name = this.nameInputTarget.value.trim();
      const reply = this.nameReplyValue.replace("%{name}", name);
      await this.showText(headingTarget, reply, 2000);
      await new Promise((resolve) => setTimeout(resolve, 800));
      await this.showText(headingTarget, this.emailQuestionValue, 2000);
    }

    headingTarget.textContent = "";
    inputContainer.classList.add("show");

    if (step === 1) {
      this.nameInputTarget.focus();
    } else {
      this.emailInputTarget.focus();
    }
  }

  handleNameEnter(event) {
    if (event.key !== "Enter") return;

    event.preventDefault();
    this.advanceFromName();
  }

  advanceFromName() {
    if (!this.nameInputTarget.value.trim()) {
      this.nameInputTarget.classList.add("is-invalid");
      return;
    }

    this.nameInputTarget.classList.remove("is-invalid");
    this.step1Target.classList.add("d-none");
    this.currentStep = 2;
    this.step2Target.classList.remove("d-none");
    this.typewriterEffect(2);
  }

  handleEmailEnter(event) {
    if (event.key !== "Enter") return;

    event.preventDefault();
    this.submitSignup();
  }

  submitSignup() {
    if (!this.emailInputTarget.value.trim()) {
      this.emailInputTarget.classList.add("is-invalid");
      return;
    }

    this.emailInputTarget.classList.remove("is-invalid");
    this.hideInputAndSubmit();
  }

  hideInputAndSubmit() {
    const inputContainer = this.inputContainer2Target;
    inputContainer.style.transition = "opacity 0.8s ease-in-out";
    inputContainer.style.opacity = "0";

    setTimeout(() => {
      inputContainer.classList.remove("show");
      this.submitForm();
    }, 800);
  }

  submitForm() {
    const formData = new FormData(this.formTarget);
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: formData,
    })
      .then((response) => response.json().then((data) => ({ response, data })))
      .then(({ response, data }) => {
        if (response.ok) {
          this.showFarewell(data.message);
          return;
        }

        this.showErrors(data.errors || []);
      })
      .catch(() => {
        this.formTarget.submit();
      });
  }

  async showFarewell(message) {
    await this.showText(this.heading2Target, message, 2500);
    this.heading2Target.textContent = message;
    this.heading2Target.style.opacity = "1";
  }

  showErrors(errors) {
    if (!this.hasErrorMessageTarget) return;

    this.errorMessageTarget.textContent = errors.join(", ");
    this.errorMessageTarget.classList.remove("d-none");
    this.inputContainer2Target.classList.add("show");
    this.inputContainer2Target.style.opacity = "1";
    this.emailInputTarget.focus();
  }
}
