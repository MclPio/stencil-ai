import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel" ]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }
}