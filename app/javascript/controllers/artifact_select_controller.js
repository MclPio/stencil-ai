import { Controller } from "@hotwired/stimulus"
import mermaidLoader from "../mermaidLoader";

// Connects to data-controller="artifact-select"
export default class extends Controller {
  static targets = [ "selection", "artifactContent" ]
  static values = { projectId: Number }

  select() {
    const url = `/projects/${this.projectIdValue}/artifacts/${this.selectionTarget.value}`
    mermaidLoader(url, this.artifactContentTarget)
  }
}
