import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="assistant-user-chat"
export default class extends Controller {
  

  connect() {
    console.log(this.element.children)
  }
}
