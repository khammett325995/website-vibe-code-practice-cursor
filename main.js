(function () {
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)")
    .matches;
  const THEME_KEY = "kh-portfolio-theme";
  const MIN_LOADER_MS = 750;

  function getStoredTheme() {
    try {
      return localStorage.getItem(THEME_KEY);
    } catch {
      return null;
    }
  }

  function setStoredTheme(value) {
    try {
      localStorage.setItem(THEME_KEY, value);
    } catch {
      /* ignore */
    }
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    setStoredTheme(theme);
  }

  function initTheme() {
    const stored = getStoredTheme();
    if (stored === "dark" || stored === "light") {
      applyTheme(stored);
      return;
    }
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      applyTheme("dark");
    } else {
      applyTheme("light");
    }
  }

  const themeToggle = document.querySelector(".theme-toggle");
  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      const current = document.documentElement.getAttribute("data-theme");
      applyTheme(current === "dark" ? "light" : "dark");
    });
  }

  initTheme();

  window
    .matchMedia("(prefers-color-scheme: dark)")
    .addEventListener("change", function (e) {
      if (getStoredTheme()) return;
      applyTheme(e.matches ? "dark" : "light");
    });

  const navToggle = document.querySelector(".nav-toggle");
  const mobileNav = document.getElementById("mobile-nav");
  if (navToggle && mobileNav) {
    navToggle.addEventListener("click", function () {
      const open = navToggle.getAttribute("aria-expanded") === "true";
      navToggle.setAttribute("aria-expanded", String(!open));
      if (open) {
        mobileNav.setAttribute("hidden", "");
      } else {
        mobileNav.removeAttribute("hidden");
      }
    });

    mobileNav.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        navToggle.setAttribute("aria-expanded", "false");
        mobileNav.setAttribute("hidden", "");
      });
    });
  }

  const pageLoader = document.getElementById("page-loader");
  let introFinished = false;

  function initSectionFades() {
    const subpage = document.body.classList.contains("subpage");
    const sections = document.querySelectorAll(
      subpage
        ? ".js-section-fade, .prose-page section.reveal"
        : ".js-section-fade"
    );
    if (!sections.length) return;

    if (reduceMotion) {
      sections.forEach(function (el) {
        el.classList.add("is-in-view");
      });
      return;
    }

    const observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-in-view");
            if (subpage) observer.unobserve(entry.target);
          } else if (!subpage) {
            entry.target.classList.remove("is-in-view");
          }
        });
      },
      {
        threshold: [0, 0.1, 0.2],
        rootMargin: "0% 0px -10% 0px",
      }
    );

    sections.forEach(function (el) {
      observer.observe(el);
    });
  }

  function finishIntro() {
    if (introFinished) return;
    introFinished = true;

    document.body.classList.remove("is-loading");
    document.body.classList.add("load-complete");
    document.documentElement.removeAttribute("aria-busy");

    if (pageLoader) {
      pageLoader.setAttribute("aria-busy", "false");
      pageLoader.classList.add("is-exit");

      const removeLoader = function (e) {
        if (e && e.propertyName !== "opacity") return;
        pageLoader.setAttribute("hidden", "");
        pageLoader.setAttribute("aria-hidden", "true");
      };

      if (reduceMotion) {
        removeLoader();
      } else {
        pageLoader.addEventListener("transitionend", removeLoader, {
          once: true,
        });
        window.setTimeout(function () {
          if (!pageLoader.hasAttribute("hidden")) removeLoader();
        }, 900);
      }
    }

    initSectionFades();
  }

  document.documentElement.setAttribute("aria-busy", "true");

  const skipLink = document.querySelector(".skip-link");
  if (skipLink) {
    skipLink.addEventListener("click", function () {
      finishIntro();
    });
  }

  if (reduceMotion) {
    finishIntro();
  } else {
    const loaderStarted = performance.now();
    const tryFinish = function () {
      const elapsed = performance.now() - loaderStarted;
      const wait = Math.max(0, MIN_LOADER_MS - elapsed);
      window.setTimeout(finishIntro, wait);
    };

    if (document.readyState === "complete") {
      tryFinish();
    } else {
      window.addEventListener("load", tryFinish);
    }
  }

  const revealSelector = document.body.classList.contains("subpage")
    ? ".reveal:not(section.reveal)"
    : ".reveal";
  const revealEls = document.querySelectorAll(revealSelector);
  if (revealEls.length && "IntersectionObserver" in window) {
    if (reduceMotion) {
      revealEls.forEach(function (el) {
        el.classList.add("is-visible");
      });
    } else {
      const observer = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              entry.target.classList.add("is-visible");
              observer.unobserve(entry.target);
            }
          });
        },
        { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
      );
      revealEls.forEach(function (el) {
        observer.observe(el);
      });
    }
  } else {
    revealEls.forEach(function (el) {
      el.classList.add("is-visible");
    });
  }
})();
