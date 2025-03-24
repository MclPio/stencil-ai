import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleKeydown(event) {
    console.log(`does it work? ${event.key}`)
    // Submit on Enter (but not with Shift)
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.closest("form").requestSubmit()
    }
    // Shift+Enter allows for normal newline behavior (no action needed)
  }
}