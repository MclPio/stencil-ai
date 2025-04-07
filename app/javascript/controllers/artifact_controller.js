import { Controller } from "@hotwired/stimulus"
import mermaid from "mermaid";

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel", "divider" ]

  connect() {
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
    });
    
    // Render charts if panel is visible on initial load
    // if (!this.panelTarget.classList.contains("hidden")) {
    //   this.renderMermaid();
    // }
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden");
    this.dividerTarget.classList.toggle("hidden");

    if (!this.panelTarget.classList.contains("hidden")) {
      this.renderMermaid();
    }
  }

  renderMermaid() {
    // Wait for DOM to update
    requestAnimationFrame(() => {
      mermaid.run({
        querySelector: '.mermaid',
        suppressErrors: false
      }).catch(err => {
        console.error('Mermaid rendering error:', err);
      });
    });
  }
}