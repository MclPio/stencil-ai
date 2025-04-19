import { Controller } from "@hotwired/stimulus"
import mermaid from "mermaid";
import Panzoom from "@panzoom/panzoom";

// Connects to data-controller="artifact-select"
export default class extends Controller {
  static targets = [ "selection", "artifactContent" ]
  static values = { projectId: Number }

  select() {
    const url = `/projects/${this.projectIdValue}/artifacts/${this.selectionTarget.value}`
    this.load(url)
    this.panzoom()
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

  panzoom() {
    const panzoom = Panzoom(this.artifactContentTarget, {maxScale: 5})
    panzoom.pan(10, 10)
    panzoom.zoom(2, { animate: true })
  }
}
