// app/javascript/controllers/viewport_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="viewport"
// This controller adds a "visible" class to the element it's connected to
// when the element enters the viewport. This is useful for triggering
// CSS animations on scroll.
export default class extends Controller {
  connect() {
    const options = {
      root: null, // relative to document viewport
      rootMargin: '0px',
      threshold: 0.1 // 10% of the element must be visible
    }

    const observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.element.classList.add("visible");
          observer.unobserve(entry.target); // Stop observing once it's visible
        }
      });
    }, options);

    observer.observe(this.element);
  }
}
