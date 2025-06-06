// app/javascript/controllers/message_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["stencilModal", "stencilIds", "selectedCount", "textarea", "submit", "buttonContent"];
  static values = { loading: Boolean };

  connect() {
    this.updateSubmitButton();
    this.loadingValue = false;
    this.selectedIds = new Set();
  }

  openStencilModal() {
    this.stencilModalTarget.showModal();
  }

  closeStencilModal() {
    this.stencilModalTarget.close();
  }


  updateStencilIds(event) {
    const checkbox = event.target;
    const id = checkbox.dataset.stencilId;

    if (checkbox.checked) {
      this.selectedIds.add(id);
    } else {
      this.selectedIds.delete(id);
    }

    // Update hidden field
    this.stencilIdsTarget.value = Array.from(this.selectedIds).join(",");
    
    // Update badge count
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = this.selectedIds.size;
    }
  }

  resetForm() {
    // Your existing reset logic
    this.selectedIds.clear();
    this.stencilIdsTarget.value = "";
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = "0";
    }
    // Uncheck all checkboxes in the modal
    this.stencilModalTarget.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
      checkbox.checked = false;
    });
  }

  startLoading() {
    this.loadingValue = true;
    this.textareaTarget.disabled = true;
    this.submitTarget.disabled = true;
    this.updateButtonContent();
  }

  resetForm(event) {
    this.loadingValue = false;
    this.textareaTarget.disabled = false;
    this.textareaTarget.value = "";
    this.textareaTarget.style.height = "auto";
    this.textareaTarget.style.height = `${this.textareaTarget.scrollHeight}px`;
    this.textareaTarget.focus();
    this.updateSubmitButton();
    this.updateButtonContent();
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      this.maybeSubmitForm();
    }
    this.updateSubmitButton();
  }

  updateSubmitButton() {
    const textarea = this.textareaTarget;
    const submitButton = this.submitTarget;

    const hasContent = textarea.value.trim().length > 0;

    if (!this.loadingValue) {
      submitButton.disabled = !hasContent;
      submitButton.classList.toggle("btn-disabled", !hasContent);
      submitButton.classList.toggle("btn-primary", hasContent);
    }
  }

  maybeSubmitForm() {
    const textarea = this.textareaTarget;
    if (textarea.value.trim().length > 0) {
      this.element.requestSubmit();
    }
  }

  updateButtonContent() {
    if (this.loadingValue) {
      this.buttonContentTarget.innerHTML =
        '<span class="loading loading-spinner loading-sm"></span>';
    } else {
      this.buttonContentTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 256 256">
          <path d="M208.49,120.49a12,12,0,0,1-17,0L140,69V216a12,12,0,0,1-24,0V69L64.49,120.49a12,12,0,0,1-17-17l72-72a12,12,0,0,1,17,0l72,72A12,12,0,0,1,208.49,120.49Z"></path>
        </svg>
      `;
    }
  }

  loadingValueChanged() {
    this.updateButtonContent();
  }
}
