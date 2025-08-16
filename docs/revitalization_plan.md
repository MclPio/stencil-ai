### Proposal: A Blueprint for Revitalizing SpecMaker

This roadmap prioritizes building a solid foundation before reconstruction, ensuring the final product is well-designed, maintainable, and high-performance.

**Phase 1: Analysis & Design**

1.  **Document Core Functionality:** Before any new work, create a concise document detailing the essential processes and components of the current application (e.g., the message/artifact flow, real-time updates, error handling). This becomes the checklist of behaviors that the new implementation must replicate and improve.
2.  **Migrate to RSpec & Factories:** With the required functionality documented, establish the new testing framework. This provides a safety net and a way to validate the behavior of the new components you will build.
3.  **Design the New Interface (Figma):** Using the functional requirements document as your guide, create the complete visual prototype in Figma. This defines the vision for the final product.

**Phase 2: Reconstruction & Optimization**

4.  **Implement a Component-Based Frontend:** Build the new UI from scratch based on your Figma designs.
    *   **Use ViewComponent:** Create a library of clean, reusable UI components.
    *   **Standardize Stimulus:** Use a main `chat_controller.js` to orchestrate the interface, fixing the current fragmentation.
5.  **Refactor the Backend Chat Flow:** With the new frontend in place, optimize the backend `MessagesController` and associated jobs for maximum performance, ensuring a fluid and responsive chat experience.
