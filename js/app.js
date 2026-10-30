/* ==========================================================================
   SHIFTLY - Core Application, Motion & Interactive Showcase Engine
   Includes: Interactive Product Showcase, Smart Parser Live Simulation,
   3D Card Tilts, Starfield Canvas, Scroll Revealer & Accessibility Focus Trap
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Initialize Canvas Starfield Background
  initStarfieldCanvas(prefersReducedMotion);

  // Initialize Interactive Cursor Spotlight
  initCursorSpotlight(prefersReducedMotion);

  // Sticky Navbar Scroll Listener
  initNavbarScroll();

  // Mobile Navigation Drawer (Focus Trap & Accessibility)
  initMobileDrawer();

  // FAQ Accordion (ARIA state sync)
  initFaqAccordion();

  // Back To Top Button
  initBackToTop();

  // Interactive Product Showcase Switcher
  initProductShowcase();

  // Interactive Smart Parser Demo
  initSmartParserDemo();

  // 3D Tilt Micro-Interactions on Showcase & Bento Cards
  initCard3DTilt(prefersReducedMotion);

  // Magnetic Buttons Micro-Interactions
  initMagneticButtons(prefersReducedMotion);

  // Animated Counter Metrics
  initMetricsCounters();

  // Robust Scroll Revealer for Cards
  initScrollAnimations(prefersReducedMotion);

  // Financial Report Export Toasts
  initFinancialExportToasts();

  // GSAP Hero Entrance Animations
  initGSAPAnimations(prefersReducedMotion);

  // GitHub Releases Downloads Modal
  initDownloadsModal();
});

/* --- Starfield Canvas Animation --- */
function initStarfieldCanvas(prefersReducedMotion) {
  const canvas = document.getElementById('bgCanvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  let width = (canvas.width = window.innerWidth);
  let height = (canvas.height = window.innerHeight);

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
    initParticles();
  });

  let particles = [];
  const numParticles = Math.min(Math.floor(width / 22), 65);

  function Particle() {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2 + 0.5;
    this.vx = (Math.random() - 0.5) * 0.35;
    this.vy = (Math.random() - 0.5) * 0.35;
    this.alpha = Math.random() * 0.6 + 0.2;
    this.color = Math.random() > 0.4 ? '#38BDF8' : (Math.random() > 0.5 ? '#818CF8' : '#C084FC');
  }

  function initParticles() {
    particles = [];
    for (let i = 0; i < numParticles; i++) {
      particles.push(new Particle());
    }
  }

  initParticles();

  function draw() {
    ctx.clearRect(0, 0, width, height);

    for (let i = 0; i < particles.length; i++) {
      const p = particles[i];
      p.x += p.vx;
      p.y += p.vy;

      if (p.x < 0) p.x = width;
      if (p.x > width) p.x = 0;
      if (p.y < 0) p.y = height;
      if (p.y > height) p.y = 0;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = p.alpha;
      ctx.fill();

      for (let j = i + 1; j < particles.length; j++) {
        const p2 = particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < 120) {
          ctx.beginPath();
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p2.x, p2.y);
          ctx.strokeStyle = '#38BDF8';
          ctx.globalAlpha = (1 - dist / 120) * 0.15;
          ctx.lineWidth = 0.8;
          ctx.stroke();
        }
      }
    }

    ctx.globalAlpha = 1;
    if (!prefersReducedMotion) {
      requestAnimationFrame(draw);
    }
  }

  if (prefersReducedMotion) {
    draw();
  } else {
    requestAnimationFrame(draw);
  }
}

/* --- Interactive Cursor Spotlight --- */
function initCursorSpotlight(prefersReducedMotion) {
  const spotlight = document.querySelector('.cursor-spotlight');
  if (!spotlight || window.innerWidth < 1024 || prefersReducedMotion) return;

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let posX = mouseX;
  let posY = mouseY;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  });

  function renderSpotlight() {
    posX += (mouseX - posX) * 0.1;
    posY += (mouseY - posY) * 0.1;

    spotlight.style.transform = `translate3d(${posX}px, ${posY}px, 0)`;
    requestAnimationFrame(renderSpotlight);
  }

  requestAnimationFrame(renderSpotlight);
}

/* --- Sticky Navbar --- */
function initNavbarScroll() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });
}

/* --- Mobile Navigation Drawer --- */
function initMobileDrawer() {
  const mobileToggle = document.getElementById('mobileToggle');
  const mobileDrawer = document.getElementById('mobileDrawer');
  const drawerOverlay = document.getElementById('drawerOverlay');
  const drawerClose = document.getElementById('drawerClose');

  if (!mobileToggle || !mobileDrawer) return;

  let previousActiveElement = null;

  function openDrawer() {
    previousActiveElement = document.activeElement;
    mobileDrawer.classList.add('active');
    if (drawerOverlay) drawerOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';

    mobileToggle.setAttribute('aria-expanded', 'true');

    setTimeout(() => {
      if (drawerClose) {
        drawerClose.focus();
      } else {
        mobileDrawer.focus();
      }
    }, 50);

    document.addEventListener('keydown', handleDrawerKeydown);
  }

  function closeDrawer() {
    mobileDrawer.classList.remove('active');
    if (drawerOverlay) drawerOverlay.classList.remove('active');
    document.body.style.overflow = '';

    mobileToggle.setAttribute('aria-expanded', 'false');

    document.removeEventListener('keydown', handleDrawerKeydown);

    if (previousActiveElement && typeof previousActiveElement.focus === 'function') {
      previousActiveElement.focus();
    } else {
      mobileToggle.focus();
    }
  }

  function handleDrawerKeydown(e) {
    if (e.key === 'Escape') {
      closeDrawer();
      return;
    }

    if (e.key === 'Tab') {
      const focusables = mobileDrawer.querySelectorAll('a[href], button:not([disabled]), input:not([disabled]), [tabindex="0"]');
      if (!focusables.length) return;

      const firstEl = focusables[0];
      const lastEl = focusables[focusables.length - 1];

      if (e.shiftKey) {
        if (document.activeElement === firstEl) {
          e.preventDefault();
          lastEl.focus();
        }
      } else {
        if (document.activeElement === lastEl) {
          e.preventDefault();
          firstEl.focus();
        }
      }
    }
  }

  mobileToggle.addEventListener('click', openDrawer);
  if (drawerClose) drawerClose.addEventListener('click', closeDrawer);
  if (drawerOverlay) drawerOverlay.addEventListener('click', closeDrawer);

  const drawerLinks = mobileDrawer.querySelectorAll('a');
  drawerLinks.forEach(link => {
    link.addEventListener('click', closeDrawer);
  });
}

/* --- FAQ Accordion --- */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');
  if (!faqItems.length) return;

  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    if (!questionBtn) return;

    questionBtn.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      faqItems.forEach(otherItem => {
        if (otherItem !== item) {
          otherItem.classList.remove('active');
          const otherBtn = otherItem.querySelector('.faq-question');
          if (otherBtn) {
            otherBtn.setAttribute('aria-expanded', 'false');
          }
        }
      });

      const newActiveState = !isActive;
      item.classList.toggle('active', newActiveState);
      questionBtn.setAttribute('aria-expanded', newActiveState ? 'true' : 'false');
    });
  });
}

/* --- Back To Top Button --- */
function initBackToTop() {
  const backToTopBtn = document.getElementById('backToTop');
  if (!backToTopBtn) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 400) {
      backToTopBtn.style.opacity = '1';
      backToTopBtn.style.pointerEvents = 'auto';
    } else {
      backToTopBtn.style.opacity = '0';
      backToTopBtn.style.pointerEvents = 'none';
    }
  });

  backToTopBtn.addEventListener('click', () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });
}

/* --- Interactive Product Showcase Tab Switcher --- */
function initProductShowcase() {
  const tabBtns = document.querySelectorAll('.showcase-tab-btn');
  const contentPanels = document.querySelectorAll('.showcase-content-panel');

  if (!tabBtns.length || !contentPanels.length) return;

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-tab');

      tabBtns.forEach(b => b.classList.remove('active'));
      contentPanels.forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const targetPanel = document.getElementById(`panel-${targetId}`);
      if (targetPanel) {
        targetPanel.classList.add('active');
      }
    });
  });
}

/* --- Interactive Smart Parser Demo --- */
function initSmartParserDemo() {
  const parserInput = document.getElementById('parserInput');
  const parserResultCard = document.getElementById('parserResultCard');
  const parseBtn = document.getElementById('parseBtn');

  if (!parserInput || !parserResultCard) return;

  function runParserDemo() {
    const text = parserInput.value.trim();
    if (!text) return;

    parserResultCard.style.opacity = '0.5';

    setTimeout(() => {
      parserResultCard.innerHTML = `
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 8px;">
          <span style="font-weight: 700; color: var(--primary); font-size: 15px;"><i class="fa-solid fa-circle-check" style="color: var(--profit);"></i> פוענח בהצלחה</span>
          <span style="font-size: 12px; color: var(--text-dim); font-family: var(--font-accent);">Shiftly Engine v1.0.3</span>
        </div>
        <div style="display: flex; flex-direction: column; gap: 8px; font-size: 14px;">
          <div style="display: flex; justify-content: space-between;"><span style="color: var(--text-muted);">תאריך משמרת:</span> <strong style="color:#FFF;">24.06.2026</strong></div>
          <div style="display: flex; justify-content: space-between;"><span style="color: var(--text-muted);">שעות פעילות:</span> <strong style="color:#FFF;">17:30 - 23:00 (5.5 שעות)</strong></div>
          <div style="display: flex; justify-content: space-between;"><span style="color: var(--text-muted);">הפסקה:</span> <strong style="color:#FFF;">45 דקות (מנוכה)</strong></div>
          <div style="display: flex; justify-content: space-between;"><span style="color: var(--text-muted);">טיפים / נסיעות:</span> <strong style="color: var(--profit);">+₪50.00 נטו</strong></div>
          <div style="display: flex; justify-content: space-between; margin-top: 8px; padding-top: 8px; border-top: 1px dashed var(--border-glass);"><span style="color: var(--text-muted);">סה״כ משוער למשמרת:</span> <strong style="color: var(--profit); font-size: 18px; font-family: var(--font-accent);">₪306.25</strong></div>
        </div>
      `;
      parserResultCard.style.opacity = '1';
    }, 250);
  }

  if (parseBtn) parseBtn.addEventListener('click', runParserDemo);
  parserInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') runParserDemo();
  });
}

/* --- 3D Card Tilt Effects --- */
function initCard3DTilt(prefersReducedMotion) {
  if (prefersReducedMotion || window.innerWidth < 1024) return;

  const tiltElements = document.querySelectorAll('.showcase-window, .bento-card, .story-card, .platform-card');

  tiltElements.forEach(el => {
    el.addEventListener('mousemove', (e) => {
      const rect = el.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const centerX = rect.width / 2;
      const centerY = rect.height / 2;

      const rotateX = ((y - centerY) / centerY) * -5;
      const rotateY = ((x - centerX) / centerX) * 5;

      el.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.01, 1.01, 1.01)`;
    });

    el.addEventListener('mouseleave', () => {
      el.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
    });
  });
}

/* --- Magnetic Buttons Interaction --- */
function initMagneticButtons(prefersReducedMotion) {
  if (prefersReducedMotion || window.innerWidth < 1024) return;

  const magneticBtns = document.querySelectorAll('.btn-primary');

  magneticBtns.forEach(btn => {
    btn.addEventListener('mousemove', (e) => {
      const rect = btn.getBoundingClientRect();
      const x = e.clientX - rect.left - rect.width / 2;
      const y = e.clientY - rect.top - rect.height / 2;

      btn.style.transform = `translate3d(${x * 0.2}px, ${y * 0.2}px, 0)`;
    });

    btn.addEventListener('mouseleave', () => {
      btn.style.transform = `translate3d(0, 0, 0)`;
    });
  });
}

/* --- Animated Metrics Counters --- */
function initMetricsCounters() {
  const metricNumbers = document.querySelectorAll('.metric-number[data-count]');
  if (!metricNumbers.length) return;

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const targetVal = parseFloat(el.getAttribute('data-count')) || 0;
        const suffix = el.getAttribute('data-suffix') || '';

        let current = 0;
        const duration = 1200;
        const startTime = performance.now();

        function step(now) {
          const progress = Math.min((now - startTime) / duration, 1);
          current = Math.floor(progress * targetVal);
          el.textContent = `${current}${suffix}`;

          if (progress < 1) {
            requestAnimationFrame(step);
          } else {
            el.textContent = `${targetVal}${suffix}`;
          }
        }

        requestAnimationFrame(step);
        obs.unobserve(el);
      }
    });
  }, { threshold: 0.2 });

  metricNumbers.forEach(el => observer.observe(el));
}

/* --- Robust Scroll Revealer for Cards & Content --- */
function initScrollAnimations(prefersReducedMotion) {
  const animateElements = document.querySelectorAll('.bento-card, .story-card, .platform-card, .section-header-centered');
  if (!animateElements.length) return;

  if (prefersReducedMotion) {
    animateElements.forEach(el => {
      el.style.opacity = '1';
      el.style.transform = 'none';
    });
    return;
  }

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.05, rootMargin: '0px 0px 100px 0px' });

  animateElements.forEach(el => {
    el.style.transition = 'opacity 0.6s cubic-bezier(0.215, 0.61, 0.355, 1), transform 0.6s cubic-bezier(0.215, 0.61, 0.355, 1)';
    const rect = el.getBoundingClientRect();
    if (rect.top < window.innerHeight + 100 && rect.bottom > -100) {
      el.style.opacity = '1';
      el.style.transform = 'translateY(0)';
    } else {
      el.style.opacity = '0';
      el.style.transform = 'translateY(30px)';
      observer.observe(el);
    }
  });
}

/* --- GSAP Entrance Animations --- */
function initGSAPAnimations(prefersReducedMotion) {
  if (prefersReducedMotion || typeof gsap === 'undefined') return;

  // Hero Text Stagger
  gsap.from('.hero-badge-pill, .hero-title, .hero-description, .hero-cta-group', {
    y: 40,
    opacity: 0,
    duration: 1,
    stagger: 0.15,
    ease: 'power3.out'
  });

  // Hero Window Entrance
  gsap.from('.showcase-window', {
    y: 60,
    opacity: 0,
    duration: 1.2,
    delay: 0.3,
    ease: 'power3.out'
  });
}

/* --- GitHub Releases Downloads Modal --- */
function initDownloadsModal() {
  if (!document.getElementById('downloadsModal')) {
    const overlay = document.createElement('div');
    overlay.className = 'drawer-overlay';
    overlay.id = 'downloadsOverlay';
    document.body.appendChild(overlay);

    const modal = document.createElement('div');
    modal.className = 'downloads-modal';
    modal.id = 'downloadsModal';
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-labelledby', 'downloadsModalTitle');
    modal.setAttribute('tabindex', '-1');

    modal.innerHTML = `
      <div class="downloads-modal-header">
        <div class="downloads-modal-title-wrap">
          <i class="fa-solid fa-cloud-arrow-down" style="color: var(--primary); font-size: 24px;"></i>
          <h3 id="downloadsModalTitle">הורדות Shiftly - גרסאות רשמיות</h3>
        </div>
        <button class="drawer-close" id="downloadsClose" aria-label="סגור חלון הורדות">
          <i class="fa-solid fa-xmark"></i>
        </button>
      </div>
      <div class="downloads-modal-body" id="downloadsModalBody">
        <div class="downloads-loading">
          <i class="fa-solid fa-spinner fa-spin" style="font-size: 32px; color: var(--primary); margin-bottom: 12px;"></i>
          <p>טוען את קבצי ההורדה והגרסאות האחרונות מ-GitHub...</p>
        </div>
      </div>
      <div class="downloads-modal-footer">
        <span style="font-size: 13px; color: var(--text-muted);">
          <i class="fa-solid fa-shield-halved" style="color: var(--profit);"></i> קבצים מאומתים וחתומים ישירות ממאגר הפיתוח
        </span>
        <a href="https://github.com/sagiv23/ShiftlyApp/releases" target="_blank" class="btn btn-outline" style="font-size: 13px; padding: 8px 16px;">
          <i class="fa-brands fa-github"></i> עמוד GitHub Releases
        </a>
      </div>
    `;
    document.body.appendChild(modal);
  }

  const downloadsModal = document.getElementById('downloadsModal');
  const downloadsOverlay = document.getElementById('downloadsOverlay');
  const downloadsClose = document.getElementById('downloadsClose');
  let previousActiveElement = null;

  function openDownloadsModal() {
    previousActiveElement = document.activeElement;
    downloadsModal.classList.add('active');
    if (downloadsOverlay) downloadsOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';

    fetchReleasesData();

    setTimeout(() => {
      if (downloadsClose) downloadsClose.focus();
    }, 50);

    document.addEventListener('keydown', handleModalKeydown);
  }

  function closeDownloadsModal() {
    downloadsModal.classList.remove('active');
    if (downloadsOverlay) downloadsOverlay.classList.remove('active');
    document.body.style.overflow = '';
    document.removeEventListener('keydown', handleModalKeydown);

    if (previousActiveElement && typeof previousActiveElement.focus === 'function') {
      previousActiveElement.focus();
    }
  }

  function handleModalKeydown(e) {
    if (e.key === 'Escape') {
      closeDownloadsModal();
    }
  }

  if (downloadsClose) downloadsClose.addEventListener('click', closeDownloadsModal);
  if (downloadsOverlay) downloadsOverlay.addEventListener('click', closeDownloadsModal);

  const downloadLinks = document.querySelectorAll('a[href*="github.com/sagiv23/ShiftlyApp"]');
  downloadLinks.forEach(link => {
    if (link.closest('#downloadsModal')) return;

    if (link.href.includes('/releases') || link.classList.contains('btn-glass') || link.classList.contains('btn-outline') && link.href.includes('github.com')) {
      link.addEventListener('click', (e) => {
        if (link.href.includes('/releases')) {
          e.preventDefault();
          openDownloadsModal();
        }
      });
    }
  });
}

async function fetchReleasesData() {
  const bodyEl = document.getElementById('downloadsModalBody');
  if (!bodyEl) return;

  try {
    const response = await fetch('https://api.github.com/repos/sagiv23/ShiftlyApp/releases/latest');
    if (!response.ok) throw new Error('Failed to fetch GitHub latest release');

    const release = await response.json();
    if (!release || !release.tag_name) {
      bodyEl.innerHTML = `
        <div class="downloads-error">
          <i class="fa-solid fa-triangle-exclamation" style="font-size: 32px; color: var(--warning); margin-bottom: 12px;"></i>
          <p>לא נמצאו גרסאות זמינות כרגע.</p>
          <a href="https://github.com/sagiv23/ShiftlyApp/releases" target="_blank" class="btn btn-primary" style="margin-top: 16px;">פתח עמוד Releases ב-GitHub</a>
        </div>
      `;
      return;
    }

    const tag = release.tag_name || 'גרסה חדשה';
    const name = release.name || tag;
    const date = release.published_at ? new Date(release.published_at).toLocaleDateString('he-IL', { year: 'numeric', month: 'long', day: 'numeric' }) : '';
    const body = release.body ? markedOrPlain(release.body) : 'אין הערות שחרור עבור גרסה זו.';
    const assets = release.assets || [];

    let assetsHtml = '';
    if (assets.length > 0) {
      assets.forEach(asset => {
        const sizeMb = (asset.size / (1024 * 1024)).toFixed(1) + ' MB';
        const downloadCount = asset.download_count ?? 0;
        const assetName = String(asset.name || '');
        const fileName = assetName.toLowerCase();
        let downloadUrl;
        try {
          const parsedUrl = new URL(asset.browser_download_url);
          if (parsedUrl.protocol !== 'https:' || parsedUrl.hostname !== 'github.com') return;
          downloadUrl = parsedUrl.href;
        } catch (_) {
          return;
        }

        let iconClass = 'fa-solid fa-file-arrow-down';
        let platformLabel = 'קובץ התקנה';

        if (fileName.endsWith('.apk')) {
          iconClass = 'fa-brands fa-android';
          platformLabel = 'Android APK';
        } else if (fileName.endsWith('.ipa')) {
          iconClass = 'fa-brands fa-apple';
          platformLabel = 'iOS IPA';
        } else if (fileName.endsWith('.exe') || fileName.endsWith('.msi')) {
          iconClass = 'fa-brands fa-windows';
          platformLabel = 'Windows Installer';
        } else if (fileName.includes('windows') && fileName.endsWith('.zip')) {
          iconClass = 'fa-brands fa-windows';
          platformLabel = 'Windows ZIP';
        } else if (fileName.includes('macos') && fileName.endsWith('.zip')) {
          iconClass = 'fa-brands fa-apple';
          platformLabel = 'macOS ZIP';
        } else if (fileName.endsWith('.dmg') || fileName.endsWith('.app.zip')) {
          iconClass = 'fa-brands fa-apple';
          platformLabel = 'macOS App';
        } else if (fileName.endsWith('.zip') || fileName.endsWith('.tar.gz')) {
          iconClass = 'fa-solid fa-file-zipper';
          platformLabel = 'ארכיון קבצים';
        }

        assetsHtml += `
          <div class="asset-item">
            <div class="asset-info">
              <div class="asset-icon"><i class="${iconClass}"></i></div>
              <div class="asset-details">
                <span class="asset-name" title="${escapeHtml(assetName)}">${escapeHtml(assetName)}</span>
                <span class="asset-meta">
                  <span>${escapeHtml(platformLabel)}</span>
                  <span>•</span>
                  <span>${escapeHtml(sizeMb)}</span>
                  <span>•</span>
                  <span>הורדות: ${escapeHtml(downloadCount)}</span>
                </span>
              </div>
            </div>
            <a href="${escapeHtml(downloadUrl)}" class="btn btn-primary" style="padding: 8px 16px; font-size: 13px; flex-shrink: 0;" target="_blank" rel="noopener noreferrer">
              <i class="fa-solid fa-download"></i> הורד
            </a>
          </div>
        `;
      });
    } else {
      assetsHtml = `
        <div style="text-align: center; padding: 12px; color: var(--text-dim); font-size: 13px;">
          לא צורפו קבצים בינאריים ישירים לשחרור זה.
        </div>
      `;
    }

    bodyEl.innerHTML = `
      <div class="release-card">
        <div class="release-header-row">
          <div class="release-version-pill">
            <i class="fa-solid fa-tag"></i> ${escapeHtml(tag)} (הגרסה האחרונה)
          </div>
          <span class="release-date">${escapeHtml(date)}</span>
        </div>
        <h4 style="color: #FFFFFF; font-size: 16px; font-weight: 700;">${escapeHtml(name)}</h4>
        <div class="release-notes">${body}</div>
        <div class="assets-list" style="display: flex; flex-direction: column; gap: 10px; margin-top: 12px;">
          ${assetsHtml}
        </div>
      </div>
    `;

  } catch (err) {
    console.error('Error fetching GitHub releases:', err);
    bodyEl.innerHTML = `
      <div class="downloads-error">
        <i class="fa-solid fa-triangle-exclamation" style="font-size: 32px; color: var(--warning); margin-bottom: 12px;"></i>
        <p>שגיאה בטעינת הנתונים מ-GitHub API.</p>
        <a href="https://github.com/sagiv23/ShiftlyApp/releases" target="_blank" class="btn btn-primary" style="margin-top: 16px;">
          <i class="fa-brands fa-github"></i> מעבר ישיר לעמוד GitHub Releases
        </a>
      </div>
    `;
  }
}

function markedOrPlain(text) {
  const isRtl = /<div\s+[^>]*dir\s*=\s*["']rtl["'][^>]*>/i.test(text);
  const markdown = text
    .replace(/<div\s+[^>]*dir\s*=\s*["']rtl["'][^>]*>/gi, '')
    .replace(/<\/div>/gi, '')
    .split(/\r?\n/)
    .map(line => {
      const escaped = escapeHtml(line.trim());
      if (/^#{1,6}\s/.test(escaped)) {
        return `<strong>${escaped.replace(/^#{1,6}\s*/, '')}</strong>`;
      }
      if (/^[*-]\s+/.test(escaped)) {
        return `• ${escaped.replace(/^[*-]\s+/, '')}`;
      }
      return escaped
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        .replace(/\*(.*?)\*/g, '<em>$1</em>');
    })
    .join('<br>');

  return isRtl ? `<div dir="rtl">${markdown}</div>` : markdown;
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/* --- Financial Report Export Toasts --- */
function initFinancialExportToasts() {
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('a, button');
    if (!btn) return;
    const text = btn.textContent || '';
    if (text.includes('ייצוא PDF') || text.includes('PDF')) {
      showShiftlyToast('דוח כספי יוצא בהצלחה כקובץ PDF נקי ומעוצב!');
    } else if (text.includes('ייצוא Excel') || text.includes('Excel') || text.includes('CSV')) {
      showShiftlyToast('דוח שכר יוצא בהצלחה כקובץ Excel (CSV) תואם למעסיק!');
    }
  });
}

function showShiftlyToast(message) {
  let toast = document.getElementById('shiftlyToast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'shiftlyToast';
    toast.className = 'shiftly-toast';
    toast.innerHTML = `<i class="fa-solid fa-circle-check"></i> <span id="shiftlyToastText"></span>`;
    document.body.appendChild(toast);
  }
  const textEl = document.getElementById('shiftlyToastText');
  if (textEl) textEl.textContent = message;

  setTimeout(() => {
    toast.classList.add('show');
  }, 50);

  setTimeout(() => {
    toast.classList.remove('show');
  }, 3500);
}

