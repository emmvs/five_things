import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "installPromptModal", "backdrop", "installButton",
        "iosSafari", "androidChromeEdge", "desktopChromeEdge", "fallbackPlatform",
        "androidChromeEdgeNative", "androidChromeEdgeFallback", "desktopChromeEdgeNative", "desktopChromeEdgeFallback"
    ]

    connect() {
        console.log('Install prompt controller connected')
        console.log(navigator.userAgent)
        
        if (this.isInstalled()) return;
 
        this.platform = this.detectPlatform();   

        this.capturedNativePrompt = null;
        if (this.platform === 'androidChromeEdge' || this.platform === 'desktopChromeEdge') {
            this.captureBeforeInstallPrompt();
        }
        
        this.showModal();
        this.updateInstallPromptShown();
    }

    dismiss() {
        this.hideModal()
    }

    install() {
        console.log('#install')

        if (this.capturedNativePrompt) {
            this.capturedNativePrompt.prompt();
        }

        this.hideModal()
    }

    showInstallButton() {
        this.showTarget('installButton')
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

    captureBeforeInstallPrompt() {
        console.log('Setting up beforeinstallprompt listener')
        window.addEventListener("beforeinstallprompt", (e) => {
            console.log('beforeinstallprompt event fired!')
            e.preventDefault();
            this.capturedNativePrompt = e;
        });
    }

    hideModal() {
        this.hideTarget('backdrop')
        this.hideTarget('installPromptModal')
    }

    showModal() {
        this.showTarget('backdrop')
        this.showTarget('installPromptModal')
        this.setModalContent();
    }

    setModalContent() {
        if (this.platform === 'androidChromeEdge') {
            console.log('androidChromeEdge1')
            if (this.capturedNativePrompt !== null) {
                this.showInstallButton();
                this.showTarget('androidChromeEdge')
                this.showTarget('androidChromeEdgeNative')
                console.log('androidChromeEdge2')
            } else {
                console.log('androidChromeEdge FALLBACK')
                this.showTarget('androidChromeEdge')
                this.showTarget('androidChromeEdgeFallback')
            }
        } else if (this.platform === 'desktopChromeEdge') {
            console.log('desktopChromeEdge1')
            if (this.capturedNativePrompt !== null) {
                this.showInstallButton();
                this.showTarget('desktopChromeEdge')
                this.showTarget('desktopChromeEdgeNative')
            } else {
                console.log('desktopChromeEdge FALLBACK')
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
        console.log('#updateInstallPromptShown')

        fetch('/user_configs/update', {
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
        })
    }

    showTarget(target) {
        console.log('showTarget called for:', target, 'exists:', this[`${target}Target`] !== undefined)
        this[`${target}Target`].style.display = "block"
    }

    hideTarget(target) {
        this[`${target}Target`].style.display = "none"
    }
}

