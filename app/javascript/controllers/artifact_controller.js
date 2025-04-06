import { Controller } from "@hotwired/stimulus"
import mermaid from "mermaid";

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel", "divider" ]

  connect() {
    mermaid.initialize({
      startOnLoad: false,  // Don't auto-render on page load
      theme: "default",
    });
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
    this.dividerTarget.classList.toggle("hidden")
  }
}