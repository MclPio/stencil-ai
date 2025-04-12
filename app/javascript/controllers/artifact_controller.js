import { Controller } from "@hotwired/stimulus"
import mermaid from "mermaid";

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel", "divider", "openButton" ]

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

  close() {
    this.panelTarget.classList.add("hidden");
    this.dividerTarget.classList.add("hidden");
    this.openButtonTarget.classList.remove("hidden");
  }

  open() {
    this.panelTarget.classList.remove("hidden");
    this.dividerTarget.classList.remove("hidden");
    this.openButtonTarget.classList.add("hidden");

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