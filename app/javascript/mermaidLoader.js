import mermaid from "mermaid";
import panzoomLoader from "./panzoomLoader";

export default function mermaidLoader(urlValue, elem) {
  fetch(urlValue)
    .then((response) => response.text())
    .then((html) => {
      elem.innerHTML = html;
      mermaid
        .run({
          querySelector: ".mermaid",
          suppressErrors: false,
        })
        .then(() => panzoomLoader(elem.querySelector("svg")))
        .catch((err) => {
          console.error("Mermaid rendering error:", err);
        });
    });
}
