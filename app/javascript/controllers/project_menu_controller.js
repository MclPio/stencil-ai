import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-menu"
export default class extends Controller {
  static targets = ["arrow", "newProjectSpan", "projectsSpan", "arrowLogoButton" ]

  connect() {
    console.log("project-menu")
  }

  expand() {
    const [firstSvg, secondSvg] = this.arrowTarget.querySelectorAll("svg");

    if (firstSvg.classList.contains("hidden")) {
      firstSvg.classList.remove("hidden");
      secondSvg.classList.add("hidden");
      this.newProjectSpanTarget.classList.add("hidden")
      this.projectsSpanTarget.classList.add("hidden")
      this.arrowLogoButtonTarget.classList.add("hidden")
      this.element.classList = "menu bg-base-200 rounded-box"
    } else {
      firstSvg.classList.add("hidden");
      secondSvg.classList.remove("hidden");
      this.newProjectSpanTarget.classList.remove("hidden")
      this.projectsSpanTarget.classList.remove("hidden")
      this.arrowLogoButtonTarget.classList.remove("hidden")
      this.element.classList = "menu bg-base-200 rounded-box w-56"
    }
  }
}
