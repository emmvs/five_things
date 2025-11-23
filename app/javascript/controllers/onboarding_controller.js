import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "step1",
    "step2",
    "step3",
    "happyThing",
    "emoji",
    "emojiGrid",
    "firstName",
    "heading1",
    "heading2",
    "heading3",
    "text1",
    "text2",
    "text3",
    "inputContainer1",
    "inputContainer2",
    "inputContainer3",
  ];

  connect() {
    this.currentStep = 1;
    this.stepContent = {
      1: {
        greeting: "Hello stranger!",
        heading: "This app is all about the things that make us happy.",
        text1: "So, first things first",
        text2: "Think of your day today",
        text3: "and tell me one thing that made you smile",
      },
      2: {
        greeting: "Wonderful!",
        heading: "Now",
        text1: "Pick your favorite emoji",
        text2: "The one that represents you best",
        text3: "",
      },
      3: {
        greeting: "Perfect!", // Will be updated with user's emoji
        heading: "One last thing",
        text1: "What should we call you?",
        text2: "",
        text3: "",
      },
    };

    // Start typewriter effect for first step
    this.typewriterEffect(1);
  }

  typewriterEffect(step) {
    const content = this.stepContent[step];
    const headingTarget = this[`heading${step}Target`];
    const textTarget = this[`text${step}Target`];
    const inputContainer = this[`inputContainer${step}Target`];

    // Helper function to show text with fade
    const showText = (element, text, duration) => {
      return new Promise((resolve) => {
        // Set text and initial state
        element.textContent = text;
        element.style.transition = "none";
        element.style.opacity = "0";

        // Force reflow for Safari compatibility
        void element.offsetHeight;

        // Use requestAnimationFrame for smoother animations on Safari
        requestAnimationFrame(() => {
          element.style.transition = "opacity 0.8s ease-in-out";
          element.style.opacity = "1";

          // Keep visible for duration, then fade out
          setTimeout(() => {
            element.style.opacity = "0";

            // Wait for fade out, then resolve
            setTimeout(resolve, 800);
          }, duration);
        });
      });
    }; // Run animation sequence
    const runSequence = async () => {
      // Show greeting
      const greetingText =
        step === 3 && this.emojiTarget.value
          ? `${content.greeting} ${this.emojiTarget.value}`
          : content.greeting;
      await showText(headingTarget, greetingText, 2000);
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Show heading
      await showText(headingTarget, content.heading, 2000);
      await new Promise((resolve) => setTimeout(resolve, 800));

      // Show text1 if exists
      if (content.text1) {
        await showText(headingTarget, content.text1, 1800);
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Show text2
        await showText(headingTarget, content.text2, 1200);
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Show text3 if exists
        if (content.text3) {
          await showText(headingTarget, content.text3, 1800);
          await new Promise((resolve) => setTimeout(resolve, 1000));
        } else {
          await new Promise((resolve) => setTimeout(resolve, 300));
        }
      } else {
        await new Promise((resolve) => setTimeout(resolve, 800));
      }

      // Clear and show input
      headingTarget.textContent = "";
      inputContainer.classList.add("show");
    };

    runSequence();
  }

  handleEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault();
      if (this.currentStep === 3) {
        this.showDashboard();
      } else {
        this.nextStep();
      }
    }
  }

  nextStep() {
    // Validate current step
    if (this.currentStep === 1 && !this.happyThingTarget.value.trim()) {
      this.happyThingTarget.classList.add("is-invalid");
      return;
    }

    if (this.currentStep === 2 && !this.emojiTarget.value) {
      alert("Please select an emoji");
      return;
    }

    // Hide current step
    this[`step${this.currentStep}Target`].classList.add("d-none");

    // Show next step
    this.currentStep++;
    const nextStep = this[`step${this.currentStep}Target`];
    nextStep.classList.remove("d-none");

    // Start typewriter effect for new step
    this.typewriterEffect(this.currentStep);
  }

  selectEmoji(event) {
    // Remove selected class from all emojis
    this.emojiGridTarget.querySelectorAll(".emoji-option").forEach((btn) => {
      btn.classList.remove("selected");
    });

    // Add selected class to clicked emoji
    event.currentTarget.classList.add("selected");

    // Store selected emoji
    this.emojiTarget.value = event.currentTarget.dataset.emoji;
  }

  selectEmojiAndAdvance(event) {
    // Select the emoji
    this.emojiGridTarget.querySelectorAll(".emoji-option").forEach((btn) => {
      btn.classList.remove("selected");
    });
    event.currentTarget.classList.add("selected");
    this.emojiTarget.value = event.currentTarget.dataset.emoji;

    // Auto-advance to next step after brief delay for visual feedback
    setTimeout(() => {
      this.nextStep();
    }, 300);
  }

  showDashboard() {
    if (!this.firstNameTarget.value.trim()) {
      this.firstNameTarget.classList.add("is-invalid");
      return;
    }

    const firstName = this.firstNameTarget.value.trim();
    const headingTarget = this.heading3Target;
    const inputContainer = this.inputContainer3Target;

    // Hide input container
    inputContainer.style.transition = "opacity 0.8s ease-in-out";
    inputContainer.style.opacity = "0";

    setTimeout(() => {
      inputContainer.classList.remove("show");

      // Show "Nice to meet you, {name}!"
      headingTarget.textContent = `Nice to meet you, ${firstName}!`;
      headingTarget.style.opacity = "0";
      setTimeout(() => {
        headingTarget.style.transition = "opacity 0.8s ease-in-out";
        headingTarget.style.opacity = "1";
      }, 100);

      setTimeout(() => {
        // Fade out greeting
        headingTarget.style.transition = "opacity 0.8s ease-in-out";
        headingTarget.style.opacity = "0";

        setTimeout(() => {
          // Show "Shall we begin?"
          headingTarget.textContent = "Shall we begin?";
          headingTarget.style.transition = "opacity 0.8s ease-in-out";
          headingTarget.style.opacity = "1";

          setTimeout(() => {
            // Fade out
            headingTarget.style.transition = "opacity 0.8s ease-in-out";
            headingTarget.style.opacity = "0";

            setTimeout(() => {
              // Store data and redirect
              const data = {
                happy_thing: this.happyThingTarget.value,
                emoji: this.emojiTarget.value,
                name: firstName,
              };

              fetch("/onboarding/create_guest_session", {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "X-CSRF-Token": document.querySelector(
                    'meta[name="csrf-token"]'
                  ).content,
                },
                body: JSON.stringify(data),
              })
                .then((response) => response.json())
                .then((data) => {
                  if (data.success) {
                    window.location.href = "/future_root";
                  }
                })
                .catch((error) => console.error("Error:", error));
            }, 800);
          }, 2000);
        }, 800);
      }, 2000);
    }, 800);
  }
}
