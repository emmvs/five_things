import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["installPrompt", "backdrop"]

    connect() {
        console.log('Install prompt controller connected')
        this.backdropTarget.style.display = "block"
        this.installPromptTarget.style.display = "block"
    }

    dismiss() {
        console.log('Dismissing install prompt')
        this.backdropTarget.style.display = "none"
        this.installPromptTarget.style.display = "none"
    }

    install() {
        console.log('Install  clicked')
    }
}

