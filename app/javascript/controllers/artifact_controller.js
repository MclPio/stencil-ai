import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel", "divider", "openButton" ]

  close() {
    this.panelTarget.classList.add("hidden");
    this.dividerTarget.classList.add("hidden");
    this.openButtonTarget.classList.remove("hidden");
  }

  open() {
    this.panelTarget.classList.remove("hidden");
    this.dividerTarget.classList.remove("hidden");
    this.openButtonTarget.classList.add("hidden");
  }
}