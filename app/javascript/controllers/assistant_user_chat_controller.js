// app/javascript/controllers/assistant_user_chat_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["messageContent", "copyMessage"];

  copy(event) {
    const button = event.currentTarget;
    const buttonId = button.dataset.id;
    const messageContent = this.messageContentTargets.find(
      (target) => target.dataset.id === buttonId
    );

    if (messageContent && "clipboard" in navigator) {
      // Clean the text: trim whitespace and normalize newlines
      const cleanedText = messageContent.textContent
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .join("\n");

      navigator.clipboard
        .writeText(cleanedText)
        .then(() => {
          this.showTooltip(button, "Text copied!", "success");
        })
        .catch((err) => {
          this.showTooltip(button, "Failed to copy: " + err.message, "error");
          console.error("Failed to copy text:", err);
        });
    } else if (!messageContent) {
      this.showTooltip(button, "No matching content!", "error");
      console.error("No matching message content found for data-id:", buttonId);
    } else {
      this.showTooltip(button, "Clipboard not supported!", "error");
      console.error("Clipboard API not supported");
    }
  }

  showTooltip(button, message, type) {
    // Remove any existing tooltips to avoid stacking
    const existingTooltip = button.parentElement.querySelector(".tooltip");
    if (existingTooltip) existingTooltip.remove();

    // Create tooltip element
    const tooltip = document.createElement("div");
    tooltip.className = `tooltip tooltip-open tooltip-top z-50 ${
      type === "success" ? "tooltip-neutral" : "tooltip-error"
    }`;
    tooltip.dataset.tip = message;

    // Position tooltip relative to button
    const buttonRect = button.getBoundingClientRect();
    tooltip.style.position = "absolute";
    tooltip.style.left = `${
      button.offsetLeft + (button.offsetWidth - tooltip.offsetWidth) / 2
    }px`; // Center horizontally
    tooltip.style.top = `${button.offsetTop - buttonRect.height + 30}px`; // 5px above button

    // Append to button's parent for relative positioning
    button.parentElement.style.position = "relative"; // Ensure parent has position: relative
    button.parentElement.appendChild(tooltip);

    // Auto-remove after 3 seconds
    setTimeout(() => {
      tooltip.remove();
    }, 3000);
  }
}
