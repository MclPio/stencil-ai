import { Controller } from "@hotwired/stimulus"
import mermaidLoader from "../mermaidLoader";

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
    mermaidLoader(url, this.artifactContentTarget)
  }
}