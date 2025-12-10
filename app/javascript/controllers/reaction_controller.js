import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
    happyThingId: Number,
  };

  connect() {
    this.tapCount = 0;
    this.tapTimer = null;
  }

  handleTap(event) {
    this.tapCount++;

    if (this.tapCount === 1) {
      this.tapTimer = setTimeout(() => {
        this.tapCount = 0;
      }, 300);
    } else if (this.tapCount === 2) {
      clearTimeout(this.tapTimer);
      this.tapCount = 0;
      this.addReaction(event);
    }
  }

  addReaction(event) {
    event.preventDefault();

    // Send request to backend
    if (this.hasUrlValue) {
      fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          emoji: "❤️",
        }),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.success) {
            if (data.deleted) {
              // Removed reaction - hide the display
              this.removeReactionDisplay();
            } else {
              // Added reaction - show animation and update display
              this.showHeartAnimation();
              this.updateReactionDisplay(data.reaction_count);
            }
          }
        })
        .catch((error) => {
          console.error("Error adding reaction:", error);
        });
    }
  }

  removeReactionDisplay() {
    const reactionDisplay = this.element.querySelector(
      ".happy_thing_reactions"
    );
    if (reactionDisplay) {
      reactionDisplay.remove();
    }
  }

  updateReactionDisplay(count) {
    // Find or create the reaction display element
    let reactionDisplay = this.element.querySelector(".happy_thing_reactions");

    if (!reactionDisplay) {
      reactionDisplay = document.createElement("div");
      reactionDisplay.className = "happy_thing_reactions";
      reactionDisplay.style.cssText = `
        position: absolute;
        top: -6px;
        right: -6px;
        font-size: 1.2rem;
        z-index: 10;
      `;
      this.element.appendChild(reactionDisplay);
    }

    // Update the display
    if (count === 1) {
      reactionDisplay.innerHTML = "<span>♥️</span>";
    } else {
      reactionDisplay.innerHTML = `<span>♥️ ${count}</span>`;
    }
  }

  showHeartAnimation() {
    const heart = document.createElement("div");
    heart.textContent = "♥️";
    heart.style.cssText = `
      position: absolute;
      font-size: 3rem;
      pointer-events: none;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      z-index: 1000;
      animation: heartFloatToCorner 0.8s ease-out forwards;
    `;

    this.element.style.position = "relative";
    this.element.appendChild(heart);

    setTimeout(() => {
      heart.remove();
    }, 800);
  }
}
