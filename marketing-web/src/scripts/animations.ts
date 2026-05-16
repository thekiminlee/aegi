/**
 * aegi — Animation System (sofi-inspired redesign)
 * Vanilla JS + CSS. No libraries.
 *
 * a) Cinematic scroll crossfade  [data-scene]
 * b) Scroll-triggered reveals     [data-reveal]
 * c) Staggered grid items         [data-stagger]
 * d) Nav scroll behavior          .nav-scrolled
 * e) Text reveals                 [data-text-reveal]
 */

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// ── a) Cinematic Scroll Crossfade ───────────────────────────────────────

function initScrollScenes() {
  const scenes = document.querySelectorAll<HTMLElement>('[data-scene]');
  if (!scenes.length) return;

  function updateScenes() {
    const viewH = window.innerHeight;

    scenes.forEach((scene, index) => {
      const rect = scene.getBoundingClientRect();
      const sceneH = rect.height;

      // Progress: 0 = scene top enters viewport bottom, 1 = scene bottom exits viewport top
      const raw = (viewH - rect.top) / (sceneH + viewH);
      const progress = Math.min(Math.max(raw, 0), 1);

      const content = scene.querySelector<HTMLElement>('[data-scene-content]');
      if (!content) return;

      let opacity: number;
      let translateY: number;

      // First scene: no fade-in, only fade-out
      if (index === 0) {
        if (progress < 0.6) {
          opacity = 1;
          translateY = 0;
        } else {
          const t = (progress - 0.6) / 0.4;
          opacity = 1 - t;
          translateY = -30 * t;
        }
      }
      // Last scene: fade-in, no fade-out
      else if (index === scenes.length - 1) {
        if (progress < 0.25) {
          const t = progress / 0.25;
          opacity = t;
          translateY = 40 * (1 - t);
        } else {
          opacity = 1;
          translateY = 0;
        }
      }
      // Middle scenes: crossfade in and out
      else {
        if (progress < 0.2) {
          // Fade in
          const t = progress / 0.2;
          opacity = t;
          translateY = 40 * (1 - t);
        } else if (progress < 0.65) {
          // Fully visible
          opacity = 1;
          translateY = 0;
        } else {
          // Fade out
          const t = (progress - 0.65) / 0.35;
          opacity = 1 - t;
          translateY = -30 * t;
        }
      }

      content.style.opacity = String(opacity);
      content.style.transform = `translateY(${translateY}px)`;
    });

    requestAnimationFrame(updateScenes);
  }

  requestAnimationFrame(updateScenes);
}

// ── b) Scroll-triggered reveals ─────────────────────────────────────────

function initReveals() {
  const els = document.querySelectorAll('[data-reveal]');
  if (!els.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.15 }
  );

  els.forEach((el) => observer.observe(el));
}

// ── c) Staggered grid items ─────────────────────────────────────────────

function initStagger() {
  const containers = document.querySelectorAll('[data-stagger]');
  if (!containers.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const children = entry.target.querySelectorAll('[data-reveal]');
          children.forEach((child, i) => {
            (child as HTMLElement).style.transitionDelay = `${i * 0.1}s`;
            child.classList.add('revealed');
          });
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.1 }
  );

  containers.forEach((el) => observer.observe(el));
}

// ── d) Nav scroll behavior ──────────────────────────────────────────────

function initNavScroll() {
  const nav = document.getElementById('main-nav');
  if (!nav) return;

  let ticking = false;

  function onScroll() {
    if (ticking) return;
    ticking = true;

    requestAnimationFrame(() => {
      if (window.scrollY > 50) {
        nav.classList.add('nav-scrolled');
      } else {
        nav.classList.remove('nav-scrolled');
      }
      ticking = false;
    });
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
}

// ── e) Text reveals ─────────────────────────────────────────────────────

function initTextReveals() {
  const els = document.querySelectorAll('[data-text-reveal]');
  if (!els.length) return;

  // Mark body so CSS knows JS is active
  document.body.classList.add('text-reveal-ready');

  els.forEach((el) => {
    const html = el.innerHTML;
    // Split on <br> tags to get lines
    const lines = html.split(/<br\s*\/?>/gi);

    el.innerHTML = lines
      .map((line, i) => {
        const delay = i * 0.15;
        return `<span class="line-wrap"><span class="line-inner" style="transition-delay: ${delay}s">${line.trim()}</span></span>`;
      })
      .join('');
  });

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.15 }
  );

  els.forEach((el) => observer.observe(el));
}

// ── f) Carousels ────────────────────────────────────────────────────────

function initCarousels() {
  document.querySelectorAll<HTMLElement>('[data-carousel]').forEach((carousel) => {
    const track = carousel.querySelector<HTMLElement>('[data-carousel-track]');
    const dots = carousel.querySelectorAll<HTMLElement>('.carousel-dot');
    const prevBtn = carousel.querySelector<HTMLElement>('.carousel-prev');
    const nextBtn = carousel.querySelector<HTMLElement>('.carousel-next');
    if (!track || !dots.length) return;

    const cards = Array.from(track.children) as HTMLElement[];
    let currentIndex = 0;

    function updateDots() {
      dots.forEach((dot, i) => dot.classList.toggle('active', i === currentIndex));
    }

    function updateArrows() {
      if (prevBtn) prevBtn.classList.toggle('disabled', currentIndex === 0);
      if (nextBtn) nextBtn.classList.toggle('disabled', currentIndex === cards.length - 1);
    }

    function scrollToCard(index: number) {
      if (index < 0 || index >= cards.length) return;
      track!.scrollTo({ left: index * track!.offsetWidth, behavior: 'smooth' });
      currentIndex = index;
      updateDots();
      updateArrows();
    }

    // Detect current card on scroll
    let scrollTimer: ReturnType<typeof setTimeout>;
    track.addEventListener('scroll', () => {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(() => {
        const w = track!.offsetWidth;
        if (w === 0) return;
        const newIndex = Math.round(track!.scrollLeft / w);
        if (newIndex !== currentIndex && newIndex >= 0 && newIndex < cards.length) {
          currentIndex = newIndex;
          updateDots();
          updateArrows();
        }
      }, 50);
    }, { passive: true });

    prevBtn?.addEventListener('click', () => scrollToCard(currentIndex - 1));
    nextBtn?.addEventListener('click', () => scrollToCard(currentIndex + 1));
    dots.forEach((dot, i) => dot.addEventListener('click', () => scrollToCard(i)));

    updateArrows();
  });
}

// ── Init ─────────────────────────────────────────────────────────────────

if (prefersReducedMotion) {
  // Show everything immediately
  document.querySelectorAll('[data-reveal]').forEach((el) => el.classList.add('revealed'));
  document.querySelectorAll('[data-text-reveal]').forEach((el) => el.classList.add('revealed'));
  // Show all scenes at full opacity
  document.querySelectorAll<HTMLElement>('[data-scene-content]').forEach((el) => {
    el.style.opacity = '1';
    el.style.transform = 'none';
  });
} else {
  initScrollScenes();
  initReveals();
  initStagger();
  initTextReveals();
}

initNavScroll();
initCarousels();
