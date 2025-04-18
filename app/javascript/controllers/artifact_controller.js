import { Controller } from "@hotwired/stimulus"
import mermaid from "mermaid";

// Connects to data-controller="artifact"
export default class extends Controller {
  static targets = [ "panel", "divider", "openButton", "selection", "artifactContent" ]
  static values = { projectId: Number }

  close() {
    this.panelTarget.classList.add("hidden");
    this.dividerTarget.classList.add("hidden");
    this.openButtonTarget.classList.remove("hidden");
  }

  open() {
    this.panelTarget.classList.remove("hidden");
    this.dividerTarget.classList.remove("hidden");
    this.openButtonTarget.classList.add("hidden");
    this.loadChartOnOpen()
  }

  loadChartOnOpen() {
    const url = `/projects/${this.projectIdValue}/artifacts/${this.selectionTarget.value}`
    this.load(url)
  }

  load(urlValue) {
    fetch(urlValue)
      .then(response => response.text())
      .then(html => {
        this.artifactContentTarget.innerHTML = html;
        mermaid.run({
          querySelector: '.mermaid',
          suppressErrors: false
        }).catch(err => {
          console.error('Mermaid rendering error:', err);
        });
      })
  }
}