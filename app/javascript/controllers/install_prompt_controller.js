import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "installPromptModal", "backdrop", "installButton", "actionsContainer", "dismissButton",
        "iosSafari", "androidChromeEdge", "desktopChromeEdge", "fallbackPlatform",
        "androidChromeEdgeNative", "androidChromeEdgeFallback", "desktopChromeEdgeNative", "desktopChromeEdgeFallback"
    ]

    connect() {
        if (this.isInstalled()) return;
 
        this.platform = this.detectPlatform();   
        this.modalShown = false;

        this.capturedNativePrompt = window.capturedNativePrompt;
        window.addEventListener('beforeinstallprompt', this.nativePromptReadyHandler);
        
        if (this.capturedNativePrompt) {
            this.showModal();
        } else {
            setTimeout(() => {
                if (!this.modalShown) {
                    this.showModal();
                }
            }, 1000);
        }
        
        this.updateInstallPromptShown();
    }

    disconnect() {
        window.removeEventListener('beforeinstallprompt', this.nativePromptReadyHandler);
    }

    nativePromptReadyHandler = () => {
        this.capturedNativePrompt = window.capturedNativePrompt;
        if (!this.modalShown) {
            this.showModal();
        } else {
            this.setModalContent();
        }
    };

    dismiss() {
        this.hideModal()
    }

    install() {
        if (this.capturedNativePrompt) {
            this.capturedNativePrompt.prompt();
        }

        this.hideModal()
    }

    showInstallButton() {
        this.showTarget('installButton')
        this.actionsContainerTarget.classList.add('button-pair')
        this.dismissButtonTarget.textContent = this.dismissButtonTarget.dataset.skipText
    }

    isInstalled() {
        return (window.matchMedia('(display-mode: standalone)').matches)
    }

    detectPlatform() {
        const userAgent = navigator.userAgent;

        if (userAgent.match(/(iPod|iPhone|iPad)/) && 
            userAgent.match(/AppleWebKit/) &&
            !userAgent.match(/CriOS/)) {
            return 'iosSafari';
        }

        if (userAgent.match(/Android/) &&
            userAgent.match(/Chrome|Edg/)) {
            return 'androidChromeEdge';
        }

        if (!userAgent.match(/Mobile/) &&
            userAgent.match(/Chrome|Edg/)) {
            return 'desktopChromeEdge';
        }

        return 'fallback';
    }

    hideModal() {
        this.hideTarget('backdrop')
        this.hideTarget('installPromptModal')
    }

    showModal() {
        this.showTarget('backdrop')
        this.showTarget('installPromptModal')
        this.setModalContent();
        this.modalShown = true;
    }

    setModalContent() {
        this.hideAllVariants();
        this.actionsContainerTarget.classList.remove('button-pair');
        this.dismissButtonTarget.textContent = this.dismissButtonTarget.dataset.notedText;
        
        if (this.platform === 'androidChromeEdge') {
            if (this.capturedNativePrompt !== null) {
                this.showInstallButton();
                this.showTarget('androidChromeEdge')
                this.showTarget('androidChromeEdgeNative')
            } else {
                this.showTarget('androidChromeEdge')
                this.showTarget('androidChromeEdgeFallback')
            }
        } else if (this.platform === 'desktopChromeEdge') {
            if (this.capturedNativePrompt !== null) {
                this.showInstallButton();
                this.showTarget('desktopChromeEdge')
                this.showTarget('desktopChromeEdgeNative')
            } else {
                this.showTarget('desktopChromeEdge')
                this.showTarget('desktopChromeEdgeFallback')
            }
        } else if (this.platform === 'iosSafari') {
            this.showTarget('iosSafari')
        } else {
            this.showTarget('fallbackPlatform')
        }
    }

    updateInstallPromptShown() {
        fetch('/user_config', {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
            },
            body: JSON.stringify({ 
                user_config: { 
                    install_prompt_shown: true 
                } 
            })
        }).catch(error => {
            console.error('Error updating install_prompt_shown:', error);
        });
    }

    showTarget(target) {
        this[`${target}Target`].style.display = "block"
    }

    hideTarget(target) {
        this[`${target}Target`].style.display = "none"
    }

    hideAllVariants() {
        this.hideTarget('androidChromeEdge');
        this.hideTarget('androidChromeEdgeNative');
        this.hideTarget('androidChromeEdgeFallback');
        this.hideTarget('desktopChromeEdge');
        this.hideTarget('desktopChromeEdgeNative');
        this.hideTarget('desktopChromeEdgeFallback');
        this.hideTarget('iosSafari');
        this.hideTarget('fallbackPlatform');
    }
}

