import { Controller } from "@hotwired/stimulus"

// Swipe right with your thumb to go back one page, like the back gesture in iOS apps.
//
// Only works in the installed app (added to the home screen). Normal browsers have their own
// back gesture, and two at once would go back twice.
//
// Usage: <main <%= tag.attributes(data: swipe_back_data) %>>, see ApplicationHelper#swipe_back_data.
// Add data-swipe-back-ignore to anything that should keep its own dragging, like a map.

// Swipe further than this share of the screen width to go back
const SHARE_OF_SCREEN_TO_GO_BACK = 0.3
// Wait until the thumb has moved this far before deciding: sideways swipe or normal scroll?
const PIXELS_BEFORE_DECIDING = 10

export default class extends Controller {
  static values = { fallbackUrl: String }

  connect() {
    this.isInstalledApp = window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true
  }

  start(event) {
    this.isFollowingThumb = false
    this.hasDecided = false
    this.isWatching = this.isInstalledApp && event.touches.length === 1 && !event.target.closest("[data-swipe-back-ignore]")

    this.startX = event.touches[0].clientX
    this.startY = event.touches[0].clientY
  }

  move(event) {
    if (!this.isWatching) return

    this.distanceX = event.touches[0].clientX - this.startX
    const distanceY = event.touches[0].clientY - this.startY

    if (!this.hasDecided) {
      if (Math.abs(this.distanceX) < PIXELS_BEFORE_DECIDING && Math.abs(distanceY) < PIXELS_BEFORE_DECIDING) return

      this.hasDecided = true
      // To the right and clearly more sideways than up or down. Anything else is a normal scroll.
      this.isFollowingThumb = this.distanceX > 0 && Math.abs(this.distanceX) > Math.abs(distanceY) * 1.5
    }

    if (!this.isFollowingThumb) return

    // Stop the page from scrolling while it follows the thumb
    event.preventDefault()
    this.slideTo(`${Math.max(this.distanceX, 0)}px`, "none")
  }

  end() {
    if (!this.isFollowingThumb) return

    this.isFollowingThumb = false

    if (this.distanceX > window.innerWidth * SHARE_OF_SCREEN_TO_GO_BACK) {
      this.slideOutAndGoBack()
    } else {
      this.slideTo("0", "transform 0.2s ease-out")
      this.element.addEventListener("transitionend", () => this.reset(), { once: true })
    }
  }

  // Turbo keeps a copy of the page to show when you come back, so save it in its normal position
  reset() {
    this.element.style.transform = ""
    this.element.style.transition = ""
  }

  slideOutAndGoBack() {
    if (this.prefersReducedMotion()) return this.goBack()

    this.slideTo("100%", "transform 0.15s ease-in")
    this.element.addEventListener("transitionend", () => this.goBack(), { once: true })
  }

  slideTo(position, transition) {
    if (this.prefersReducedMotion()) return

    this.element.style.transition = transition
    this.element.style.transform = `translateX(${position})`
  }

  // Opened straight from a link or a notification there is no page to go back to,
  // so go to the fallback (the dashboard) instead
  goBack() {
    if (window.history.length > 1) {
      window.history.back()
    } else {
      window.Turbo.visit(this.fallbackUrlValue)
    }
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
