// Minimal client script; kept deterministic so the COPY layer digest is stable.
document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("status");
  if (el) {
    el.textContent = "served from test-repo-nr-1";
  }
});
