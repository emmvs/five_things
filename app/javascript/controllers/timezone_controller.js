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

  maybeUpdateTimezone(timezone, userId) {
    const previous = localStorage.getItem('date')
    const today = new Date().toISOString()
    const sixHoursPassed = this.hasSixHoursPassed(previous, today)

    if (sixHoursPassed) {
      localStorage.setItem('date', today)
      this.updateTimezone(timezone, userId)
    }
  }

  hasSixHoursPassed(previous, today) {
    if (!previous) return true
    
    const sixHours = 6 * 60 * 60 * 1000
    return (new Date(today).getTime() > new Date(previous).getTime() + sixHours)
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
