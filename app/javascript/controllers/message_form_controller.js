// app/javascript/controllers/message_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textarea", "submit" ]

  handleKeydown(event) {
    // Submit on Enter (but not with Shift)
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.maybeSubmitForm()
    }
    // Update submit button state
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    const textarea = this.textareaTarget
    const submitButton = this.submitTarget

    // Trim to check for actual content
    const hasContent = textarea.value.trim().length > 0

    // Disable/enable button based on content
    submitButton.disabled = !hasContent

    // Optional: Add visual indication
    if (hasContent) {
      submitButton.classList.remove('btn-disabled')
      submitButton.classList.add('btn-primary')
    } else {
      submitButton.classList.add('btn-disabled')
      submitButton.classList.remove('btn-primary')
    }
  }

  maybeSubmitForm() {
    const textarea = this.textareaTarget

    // Only submit if there's non-whitespace content
    if (textarea.value.trim().length > 0) {
      this.element.requestSubmit()
    }
  }

  resetForm(event) {
    this.element.reset()

    // Manually trigger the resize to reset the textarea height
    const textarea = this.textareaTarget
    textarea.style.height = 'auto'
    textarea.style.height = `${textarea.scrollHeight}px`

    // Reset submit button state
    this.updateSubmitButton()
  }

  connect() {
    // Initial state setup
    this.updateSubmitButton()
  }
}