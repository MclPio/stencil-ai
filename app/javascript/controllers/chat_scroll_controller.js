import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-scroll"
export default class extends Controller {
  connect() {
    document.addEventListener('turbo:load', () => {
      this.scrollToBottom()
    })

  }

  scrollToBottom() {
    document.documentElement.scrollTop = document.documentElement.scrollHeight
  }
}
