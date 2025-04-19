import { Controller } from "@hotwired/stimulus"
import Panzoom from "@panzoom/panzoom"

// Connects to data-controller="svg-zoom"
export default class extends Controller {
  static targets = [ "diagram" ]

  zoom() {
    const elem = this.diagramTarget
    toggleFullscreen(elem)
  }

  reset() {
    const svg = this.diagramTarget.querySelector('svg');
    if (svg && svg.panzoom) {
      svg.panzoom.reset();
    }
  }

}

function toggleFullscreen(elem) {
  if (!document.fullscreenElement) {
    elem.requestFullscreen().catch((err) => {
      alert(
        `Error attempting to enable fullscreen mode: ${err.message} (${err.name})`,
      );
    });
  } else {
    document.exitFullscreen();
  }
}
