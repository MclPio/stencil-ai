import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-expand"
export default class extends Controller {
  connect() {
    this.resize()
  }

  resize() {
    const textarea = this.element

    // Reset height to auto so we can get the scroll height
    textarea.style.height = 'auto'

    // Get the scroll height
    const scrollHeight = textarea.scrollHeight

    // Calculate the new height, capping at max-height (12rem in our CSS)
    const maxHeight = parseInt(getComputedStyle(textarea).maxHeight)
    const newHeight = Math.min(scrollHeight, maxHeight)

    // Set the new height
    textarea.style.height = `${newHeight}px`
  }
}
