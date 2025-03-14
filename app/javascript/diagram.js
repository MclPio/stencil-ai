// Add this to your JavaScript files
document.addEventListener('turbo:load', function() {
  initMermaidInteractions();
});

function initMermaidInteractions() {
  const diagramContainer = document.querySelector('.mermaid-container');
  if (!diagramContainer) return;

  const zoomInBtn = document.getElementById('zoom-in');
  const zoomOutBtn = document.getElementById('zoom-out');
  const resetBtn = document.getElementById('reset-view');
  const fullscreenBtn = document.getElementById('fullscreen');
  const diagramWrapper = document.getElementById('diagram-wrapper');

  let scale = 1;
  let translateX = 0;
  let translateY = 0;
  let isDragging = false;
  let startX = 0;
  let startY = 0;

  // Function to update the transform
  function updateTransform() {
    diagramContainer.style.transform = `scale(${scale}) translate(${translateX}px, ${translateY}px)`;
    diagramContainer.dataset.scale = scale;
    diagramContainer.dataset.translateX = translateX;
    diagramContainer.dataset.translateY = translateY;
  }

  // Zoom in
  zoomInBtn.addEventListener('click', function() {
    scale += 0.1;
    updateTransform();
  });

  // Zoom out
  zoomOutBtn.addEventListener('click', function() {
    if (scale > 0.2) {
      scale -= 0.1;
      updateTransform();
    }
  });

  // Reset view
  resetBtn.addEventListener('click', function() {
    scale = 1;
    translateX = 0;
    translateY = 0;
    updateTransform();
  });

  // Fullscreen toggle
  fullscreenBtn.addEventListener('click', function() {
    const diagramSection = fullscreenBtn.closest('.card');

    if (!document.fullscreenElement) {
      if (diagramSection.requestFullscreen) {
        diagramSection.requestFullscreen();
      }
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
    }
  });

  // Pan functionality
  diagramContainer.addEventListener('mousedown', function(e) {
    isDragging = true;
    startX = e.clientX - translateX;
    startY = e.clientY - translateY;
    diagramContainer.style.cursor = 'grabbing';
  });

  document.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    translateX = e.clientX - startX;
    translateY = e.clientY - startY;
    updateTransform();
  });

  document.addEventListener('mouseup', function() {
    isDragging = false;
    diagramContainer.style.cursor = 'grab';
  });

  // Initialize
  diagramContainer.style.cursor = 'grab';
  diagramContainer.style.transformOrigin = 'center center';

  // Also handle wheel for zooming
  diagramWrapper.addEventListener('wheel', function(e) {
    if (e.ctrlKey) {
      e.preventDefault();
      const delta = e.deltaY > 0 ? -0.05 : 0.05;
      const newScale = scale + delta;

      if (newScale >= 0.2 && newScale <= 3) {
        scale = newScale;
        updateTransform();
      }
    }
  }, { passive: false });
}