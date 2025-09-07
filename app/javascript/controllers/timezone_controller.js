import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { userId: String }

  connect() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
    const userId = this.userIdValue

    if (userId && userId !== '0') {
      this.maybeUpdateTimezone(timezone, userId)
    }
  }

  onHappyThingFormSubmit() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
    const userId = this.userIdValue

    if (userId && userId !== '0') {
      this.updateTimezone(timezone, userId)
    }
  }

  maybeUpdateTimezone(timezone, userId) {
    const previous = localStorage.getItem('date')
    const today = new Date().toISOString()
    const twelveHoursPassed = this.hasTwelveHoursPassed(previous, today)

    if (twelveHoursPassed) {
      localStorage.setItem('date', today)
      this.updateTimezone(timezone, userId)
    }
  }

  hasTwelveHoursPassed(previous, today) {
    if (!previous) return true
    
    const twelveHours = 12 * 60 * 60 * 1000
    return (new Date(today).getTime() > new Date(previous).getTime() + twelveHours)
  }

  async updateTimezone(timezone, userId) {
    try {
      await fetch(`/users/${userId}/update_timezone`, {
        method: 'POST',
        body: JSON.stringify({ timezone }),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
    } catch (error) {
      console.error('Failed to update timezone:', error)
    }
  }
}
