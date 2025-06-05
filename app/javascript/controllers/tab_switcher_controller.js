import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tab-switcher"
export default class extends Controller {
  static targets = [ "tab", "panel"];

  connect() {
    const activeTab = this.tabTargets.find(tab => tab.classList.contains("tab-active")) || this.tabTargets[0];
    this.showPanel(activeTab);  }

  selectTab(event) {
    const selectedTab = event.currentTarget

    this.tabTargets.forEach(element => {
      if (element.dataset.tabId !== selectedTab.dataset.tabId) {
        element.classList.remove("tab-active")
      } else {
        element.classList.add("tab-active")
      }
    });
    this.showPanel(selectedTab)
  }

  showPanel(selectedTab) {
    this.panelTargets.forEach(panel => {
      if (panel.dataset.panelId === selectedTab.dataset.tabId) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
