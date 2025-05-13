import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    // Make the toast visible with animation
    setTimeout(() => {
      this.element.classList.add('toast-visible')
    }, 100)
    
    // Auto-dismiss after timeout
    setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }
  
  dismiss() {
    this.element.classList.remove('toast-visible')
    this.element.classList.add('toast-hidden')
    
    // Remove from DOM after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
  
  get timeoutValue() {
    return parseInt(this.element.dataset.toastTimeout) || 5000
  }
}