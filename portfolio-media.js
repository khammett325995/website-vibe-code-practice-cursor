/**
 * Lightbox for legacy portfolio galleries (onclick="imageChange(...)").
 * Media paths are rewritten at build time; this only provides interactivity.
 */
function imageChange(selectedImageId, imageTextId, clickedImg) {
  var expandImg = document.getElementById(selectedImageId);
  var imgText = document.getElementById(imageTextId);
  if (!expandImg || !imgText || !clickedImg) return;

  expandImg.src = clickedImg.src;
  expandImg.alt = clickedImg.alt || "";
  imgText.textContent = clickedImg.alt || "";

  var parent = expandImg.parentElement;
  if (parent) {
    parent.style.display = "block";
  }
}

document.addEventListener("click", function (e) {
  var close = e.target.closest(".images-container .close-button");
  if (close && close.parentElement) {
    close.parentElement.style.display = "none";
  }
});

document.addEventListener("keydown", function (e) {
  if (e.key !== "Escape") return;
  document.querySelectorAll(".images-container").forEach(function (box) {
    if (box.style.display === "block") box.style.display = "none";
  });
});
