import Panzoom from "@panzoom/panzoom";

export default function panzoomLoader(elem) {
  const panzoom = Panzoom(elem, { maxScale: 5 });
  elem.parentElement.addEventListener("wheel", panzoom.zoomWithWheel);
}
