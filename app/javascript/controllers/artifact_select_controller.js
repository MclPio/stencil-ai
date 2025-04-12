import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="artifact-select"
export default class extends Controller {
  static targets = [ "modelErd", "topLevelRoadmapDiagram", "valueFlowDiagram", "selection" ]

  // When a selectionTarget returns a value, hide the rest
  // keep the selectionTarget.value by removing the hidden class
  connect() {
    
  }

  select() {
    console.log(this.selectionTarget.value)
  }
}
