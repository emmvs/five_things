import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["installPromptModal", "backdrop"]

    connect() {
        console.log('Install prompt controller connected')
        if (!this.isInstalled()) {
            this.showModal()
        }
    }

    dismiss() {
        console.log('Dismissing install prompt')
        this.hideModal()
    }

    install() {
        console.log('Install  clicked')
        this.hideModal()
    }

    isInstalled() {
    }

    detectPlatform() {
    }

    captureBeforeInstallPrompt() {
    }

    hideModal() {
        this.backdropTarget.style.display = "none"
        this.installPromptModalTarget.style.display = "none"
    }

    showModal() {
        this.backdropTarget.style.display = "block"
        this.installPromptModalTarget.style.display = "block"
    }

    updateModalContent() {
    }

    updateInstallPromptShown() {
    }
}

