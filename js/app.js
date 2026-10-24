/* ==========================================================================
   SHIFTLY - Core Application, Accessibility & Motion Engine
   Provides: Accessible Canvas Particles, Cursor Spotlight, Navbar & Drawer
   Focus Trap, FAQ Accordion ARIA, Scroll-triggered Animations
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // Respect system reduced motion settings for animations (WCAG 2.3.3)
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Initialize Canvas Particle Starfield Background
  initStarfieldCanvas(prefersReducedMotion);

  // Initialize Interactive Cursor Follower Spotlight
  initCursorSpotlight(prefersReducedMotion);

  // Sticky Navbar Scroll State
  initNavbarScroll();

  // Mobile Navigation Drawer (Focus Trap & ARIA)
  initMobileDrawer();

  // FAQ Accordion (ARIA state sync)
  initFaqAccordion();

  // Back To Top Button
  initBackToTop();

  // Scroll Entrance Animations
  initScrollAnimations();

  // In-App GitHub Releases Downloads Center Modal
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
  const numParticles = Math.min(Math.floor(width / 20), 60);

  function Particle() {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2 + 0.5;
    this.vx = (Math.random() - 0.5) * 0.4;
    this.vy = (Math.random() - 0.5) * 0.4;
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

      // Connect nearby particles with subtle glowing lines
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
    // Single static render for reduced motion
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

/* --- Mobile Navigation Drawer (Accessibility Focus Trap & ARIA) --- */
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

    // Focus close button or first interactive element inside drawer
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

    // Restore focus to mobile toggle button
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

/* --- FAQ Accordion (ARIA State Sync) --- */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');
  if (!faqItems.length) return;

  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    if (!questionBtn) return;

    questionBtn.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      // Close all other open accordion items
      faqItems.forEach(otherItem => {
        if (otherItem !== item) {
          otherItem.classList.remove('active');
          const otherBtn = otherItem.querySelector('.faq-question');
          if (otherBtn) {
            otherBtn.setAttribute('aria-expanded', 'false');
          }
        }
      });

      // Toggle current
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

/* --- Scroll Entrance Observer --- */
function initScrollAnimations() {
  const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
  };

  const animateElements = document.querySelectorAll('.animate-on-scroll');

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animated');
        obs.unobserve(entry.target);
      }
    });
  }, observerOptions);

  animateElements.forEach(el => observer.observe(el));
}

/* --- GitHub Releases Downloads Center Modal --- */
function initDownloadsModal() {
  // 1. Create Modal & Overlay markup if not present
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

    // Fetch releases data
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

  // Intercept all links pointing to GitHub releases (including ShiftlyApp if any)
  const downloadLinks = document.querySelectorAll('a[href*="github.com/sagiv23/ShiftlyApp"]');
  downloadLinks.forEach(link => {
    // Do not intercept links inside the downloads modal
    if (link.closest('#downloadsModal')) return;

    // Only intercept if it's a releases link or download button
    if (link.href.includes('/releases') || link.classList.contains('btn-glass') || link.classList.contains('btn-outline') && link.href.includes('github.com')) {
      link.addEventListener('click', (e) => {
        // If it's the main repo link without releases, we can still open releases or allow repo link. But for releases links:
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
          platformLabel = 'iOS IPA (נדרשת חתימה להתקנה)';
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
        <div class="assets-list">
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
